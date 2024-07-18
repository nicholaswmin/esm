#!/bin/bash

read -p "Enter a description:" description
read -p "Enter your username:" author

# LC_CTYPE=C && LANG=C && find ./ \( -iname \*.js -o -iname \*.md -o -iname \*.json \) -print0 | xargs -0 sed -i '' "s/<project>/kostas/g"

sed -i '' "s/<description>/$description/g" package.json
sed -i '' "s/<author>/${author//@/}/g" package.json
sed -i '' "s/<author>/${author//@/}/g" LICENSE
sed -i '' "s/<year>/$(date +%Y)/g" LICENSE

#git add --all
#git commit -am"feat: init project name"
