#!/bin/bash

# ******************
# Utilities
# ******************

# reset in case of error
cleanup() {
  printf "\n\x1B[31m- Last command failed. Resetting and exiting ...\x1B[0m\n"
  git reset --hard
  git clean --f
}
trap cleanup ERR

# Exit script if a statement returns
# a non-true return value.
set -e
#!/bin/bash

#######################################
# Deletes a property from a JSON file
#
# Example:
#
# deleteKeyFromJSONFile "version" package.json
#
# Removes the "version" property of file "package.json""
#
# Globals:
# - none
# Arguments:
# - key : the JSON key/property name to remove
# - file: the JSON file path
# Returns:
# - 0 if key was deleted
# - 1 otherwise
#######################################
deleteKeyFromJSONFile () {
    key=$1
    file=$2

    # verify params

    if ! [ "$key" ]; then
        echo "- Missing \"key\" parameter. Aborting..."
        return 1
    fi

    if ! [ "$file" ]; then
        echo "- Missing \"file\" parameter"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "- File: $file does not exist"
        return 1
    fi

    line_num=$(grep -n "${key}" "$file" | head -1 | grep -Eo '^[^:]+')

    if [[ -z "$line_num" ]]; then
        echo "- Cannot find key: \"${1}\" in: ${file}"
        return 1
    fi

    # get our line, plus the previous line
    line=$(sed -n "${line_num}"p "$file")
    prev_line_num=$((line_num - 1))
    prev_line=$(sed -n "${prev_line_num}"p "$file")

    # remove dangling comma of previous line:
    if ! [[ "${line: -1}" =~ ^[,]$ ]]; then
        if  [ -n "$prev_line" ] && [[ "${prev_line: -1}" =~ ^[,]$ ]]; then
            sed  -i "" $prev_line_num's/,//g' $file
        fi
    fi

    # remove our line
    sed -i "" "${line_num}d" "$file"

    return 0
}


# ******************
# Start script
# ******************


printf "\x1B[34mStarting up...\x1B[0m\n"


# Default user inputs


# project name is current working directory
project=${PWD##*/}
nodev=$(npm view node version | cut -d '.' -f1)
author=$(gh api user --jq .login)


## Gather user inputs ##


# Module Description
# description must have at least 3 characters
while [[ -z $description ]] || (( ${#description} < 3 )) ; do
    printf "\nEnter package description: "
    read -r description
done

# Minimum supported node version
# must be a positive integer
read -r -e -p "Enter min. NodeJS version [latest: $nodev]: " -i "$nodev" nodev
while ! [[ "$nodev" =~ ^[0-9]+$ ]]; do
    printf "\nEnter minimum NodeJS version: "
    read -r nodev
done

# Module Author
# author must be a valid github username (no "@", min length = 3 etc..)
read -r -e -p "Enter your username: " -i "$author" author
while ! [[ "$author" =~ ^[[:alpha:][:digit:]_-]{3,15}$ ]]; do
    printf "\nEnter your username: "
    read -r author
done

# Should ESLint be installed?
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


# Set package.json node version #

# note: do this before anything else
# so we can `npm install` in the
# next steps otherwise npm commands
# will fail

sed -i '' "s/{{nodev}}/$(echo "$nodev" | grep -o -E '[0-9]+')/g" package.json


# Add ESLint #


# if user said "yes" to prompt

# update npm
npm i -g npm@latest
# install ESLint
npm i --save-dev eslint @eslint/js
# install Node ESLint globals
npm i -D @eslint/js globals

# add ESlint to `npm run checks`
sed -i '' "s/{{eslint-cmd}}/npx eslint \&\& /g" package.json
printf "\n\x1B[34madded ESlint & NodeJS globals\x1B[0m\n"

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


else
# if user said "no" and doesnt want ESLint

# remove the replacement token from "npm run checks",
sed -i '' "s/{{eslint-cmd}}//g" package.json
# generate a lockfile anyway
npm i
fi


#  Conventional Commits #


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


# Replacements #


# replace generic doc stuff
sed -i '' "s/{{description}}/$description/g" package.json README.md
sed -i '' "s/{{author}}/${author//@/}/g" package.json README.md LICENSE
sed -i '' "s/{{year}}/$(date +%Y)/g" LICENSE

# recursively replace project name
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/{{project}}/${project}/g"
LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/esm-zero/${project}/g"



# Github Actions/CI #

# activate workflows
mv .github/workflows/checks.sample    .github/workflows/checks.yml
mv .github/workflows/codeql.sample    .github/workflows/codeql.yml
mv .github/workflows/test:unit.sample .github/workflows/test:unit.yml

# replace dummy badges with working ones
test_badge="https://github.com/${author}/${project}/actions/workflows/test:unit.yml/badge.svg"
codeql_badge="https://github.com/${author}/${project}/actions/workflows/codeql.yml/badge.svg"
sed -i '' "s,https://img.shields.io/badge/tests:unit-passing-green,$test_badge,g" README.md
sed -i '' "s,https://img.shields.io/badge/CodeQL-passing-green,$codeql_badge,g" README.md


# Remove template-setup boilerplate

# Remove the `setup` npm script
deleteKeyFromJSONFile "setup" package.json

# Remove the top overview section from README
overview_start=$( grep -n "overview-start" README.md | cut -f1 -d:)
overview_end=$( grep -n "overview-end" README.md | cut -f1 -d:)
sed -i "" "${overview_start},$((overview_end+1))d" README.md

printf "\n\x1B[34m- setup Github Actions and badges\x1B[0m\n"
printf "\n\x1B[34m- added Conventional Commit git hook\x1B[0m\n"
printf "\n\x1B[34m- filled-in project details\x1B[0m\n"
printf "\n\x1B[34m- fixed-up package.json\x1B[0m\n"
printf "\n\x1B[32m- Cleaning up, commiting and pushing 🦄 ...\x1B[0m\n"

# schedule commit & push in 2 seconds
#
# note: must be done in an async daemon so we
# can delete this file and have it pushed in the commit
nohup >/dev/null & sleep 2 && git add --all && git commit -am"feat: init project" && git push origin main

# delete this file
# note: runs *before* the above command, so it gets commited
rm -- "$0"
