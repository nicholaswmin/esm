#!/bin/bash

# Exit script if a statement returns a non-true return value.
set -e

printf "\x1B[34mStarting up...\x1B[0m\n"

# Gather all user inputs

# project name is current working directory
project=${PWD##*/}

# gather required user inputs
while [[ -z $description ]]; do
    printf "\nEnter package description: "
    read -r description
done

while ! [[ "$nodev" =~ ^[0-9]+$ ]]; do
    printf "\nEnter minimum supported node version: (i.e: 20, w/o 'v') "
    read -r nodev
done

while [[ -z $author ]]; do
    printf "\nEnter your Github username: (i.e tom, w/o '@') "
    read -r author
done

# ask if needed
until [[ $eslint == *y*  ]] || [[ $eslint == *n* ]];  do
    printf "\nNeed ESLint ? (y/n) "
    read -r eslint
done

# Github Actions/CI

# activate workflow files
# note: run before `sed` cmds so badge URLs are replaced: {{author}}/{{project}}
mv .github/workflows/checks.sample    .github/workflows/checks.yml
mv .github/workflows/codeql.sample    .github/workflows/codeql.yml
mv .github/workflows/test:unit.sample .github/workflows/test:unit.yml

# replace fake badges with working ones
test_badge_real="https://github.com/{{author}}/{{project}}/actions/workflows/test:unit.yml/badge.svg"
codeql_badge_real="https://github.com/{{author}}/{{project}}/actions/workflows/codeql.yml/badge.svg"

sed -i '' "s,https://img.shields.io/badge/tests:unit-passing-green,$test_badge_real,g" README.md
sed -i '' "s,https://img.shields.io/badge/CodeQL-passing-green,$codeql_badge_real,g" README.md

# replace general stuff
sed -i '' "s/{{description}}/$description/g" package.json README.md
sed -i '' "s/{{author}}/${author//@/}/g" package.json README.md LICENSE
sed -i '' "s/{{year}}/$(date +%Y)/g" LICENSE
sed -i '' "s/{{nodev}}/$(echo "$nodev" | grep -o -E '[0-9]+')/g" package.json

# recursively replace project name
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/{{project}}/${project}/g"
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/esm-zero/${project}/g"

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

printf "\n\x1B[34msetup Github Actions and badges\x1B[0m\n"
printf "\n\x1B[34mfilled-in project details\x1B[0m\n"
printf "\n\x1B[34mfixed-up package.json\x1B[0m\n"
printf "\n\x1B[34madded Conventional Commit git hook\x1B[0m\n"

printf "\n\x1B[32mDone! Cleaning up, commiting and pushing 🦄 ...\x1B[0m\n"

# schedule commit & push in 2 seconds
nohup >/dev/null & sleep 2 && git add --all && git commit -am"feat: init project" && git push origin main

# delete this file
# note: runs *before* the above command, so it gets commited
rm -- "$0"
