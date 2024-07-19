#!/bin/bash

# Exit script if a statement returns
# a non-true return value.
set -e

# Start Script

printf "\x1B[34mStarting up...\x1B[0m\n"

# Default user inputs

# project name is current working directory
project=${PWD##*/}
nodev=$(npm view node version | cut -d '.' -f1)
author=$(gh api user --jq .login)

# gather required user inputs
# description must have at least 3 characters
while [[ -z $description ]] || (( ${#description} < 3 )) ; do
    printf "\nEnter package description: "
    read -r description
done

# node version must be a positive integer

# Gather user inputs

read -r -e -p "Enter min. NodeJS version [latest: $nodev]: " -i "$nodev" nodev
while ! [[ "$nodev" =~ ^[0-9]+$ ]]; do
    printf "\nEnter minimum NodeJS version: "
    read -r nodev
done

# author must be a valid github username (no "@", min length = 3 etc..)
read -r -e -p "Enter your username: " -i "$author" author
while ! [[ "$author" =~ ^[[:alpha:][:digit:]_-]{3,15}$ ]]; do
    printf "\nEnter your username: "
    read -r author
done

until [[ $eslint =~ ^[YyNn]$ ]]; do
    printf "\nNeed ESLint (with NodeJS globals) ? (y/n) "
    read -r eslint
done

# trim trailing and leading whitespace

nodev="${nodev#"${nodev%%[![:space:]]*}"}"
nodev="${nodev%"${nodev##*[![:space:]]}"}"

author="${author#"${author%%[![:space:]]*}"}"
author="${author%"${author##*[![:space:]]}"}"

description="${description#"${description%%[![:space:]]*}"}"
description="${description%"${description##*[![:space:]]}"}"

# Replace node version
# note: do this early so we can npm install

sed -i '' "s/{{nodev}}/$(echo "$nodev" | grep -o -E '[0-9]+')/g" package.json

# ESLint

if [[ $eslint =~ ^[Yy]$ ]]
then

# create ESlint config file
cat > eslint.config.js << EOF
import globals from 'globals'
import pluginJs from '@eslint/js'

export default [
    { languageOptions: { globals: globals.node }},
    pluginJs.configs.recommended,
]
EOF

# install ESLint
npm install -g npm@latest
npm i -D @eslint/js globals

# add ESlint to `npm run checks`
sed -i '' "s/{{eslint-cmd}}/npx eslint \&\& /g" package.json
printf "\n\x1B[34madded ESlint & NodeJS globals\x1B[0m\n"

else

# remove the replacement token from "npm run checks",
sed -i '' "s/{{eslint-cmd}}//g" package.json
# generate a lockfile manually since we didnt install anything
npm i
fi

#  Conventional Commits

# create hook
# taken from: https://github.com/joaobsjunior/sh-conventional-commits
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

REGEX="^((Merge[ a-z-]* branch.*)|(Revert*)|((build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(.*\))?!?: .*))"

FILE=`cat $1` # File containing the commit message

echo "Commit Message: ${FILE}"

if ! [[ $FILE =~ $REGEX ]]; then
    printf "\n\x1B[31mCommit aborted for not following the Conventional Commit standard.​\x1B[0m\n" >&2
	printf "\ncommit message must be in format: \"<type>: <message>\"\n"
	printf "\n - where <type> can be any of: build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test\n"
	printf " - example: git commit -am \"docs: added code examples in usage sections\"\n"
	printf " - more info: https://www.conventionalcommits.org\n\n"
	exit 1
else
	printf "\n\x1B[34mValid commit message.​\x1B[0m\n"
fi
EOF

# ... ensure its executable
git config core.hooksPath .git/hooks
chmod ug+x .git/hooks/commit-msg

# Replacements

# replace general stuff
sed -i '' "s/{{description}}/$description/g" package.json README.md
sed -i '' "s/{{author}}/${author//@/}/g" package.json README.md LICENSE
sed -i '' "s/{{year}}/$(date +%Y)/g" LICENSE

# recursively replace project name
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/{{project}}/${project}/g"
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/esm-zero/${project}/g"

# Github Actions/CI

# activate workflow files
mv .github/workflows/checks.sample    .github/workflows/checks.yml
mv .github/workflows/codeql.sample    .github/workflows/codeql.yml
mv .github/workflows/test:unit.sample .github/workflows/test:unit.yml

# replace dummy badges with working ones
test_badge="https://github.com/${author}/${project}/actions/workflows/test:unit.yml/badge.svg"
codeql_badge="https://github.com/${author}/${project}/actions/workflows/codeql.yml/badge.svg"

sed -i '' "s,https://img.shields.io/badge/tests:unit-passing-green,$test_badge,g" README.md
sed -i '' "s,https://img.shields.io/badge/CodeQL-passing-green,$codeql_badge,g" README.md

# Cleanups

# Remove the `setup` npm script
#
# note: dont add the "setup" script as last script in "scripts:",
# otherwise a dangling comma remains
setup_script_lineno=$( grep -n '"setup":' package.json | cut -f1 -d:)
sed -i "" "${setup_script_lineno}d" package.json

# Remove the template repo overview section from README
overview_start=$( grep -n "overview-start" README.md | cut -f1 -d:)
overview_end=$( grep -n "overview-end" README.md | cut -f1 -d:)
sed -i "" "${overview_start},$((overview_end+1))d" README.md

printf "\n\x1B[34m- setup Github Actions and badges\x1B[0m\n"
printf "\n\x1B[34m- added Conventional Commit git hook\x1B[0m\n"
printf "\n\x1B[34m- filled-in project details\x1B[0m\n"
printf "\n\x1B[34m- fixed-up package.json\x1B[0m\n"
printf "\n\x1B[32m- Cleaning up, commiting and pushing 🦄 ...\x1B[0m\n"

# schedule commit & push in 2 seconds
nohup >/dev/null & sleep 2 && git add --all && git commit -am"feat: init project" && git push origin main

# delete this file
# note: runs *before* the above command, so it gets commited
rm -- "$0"
