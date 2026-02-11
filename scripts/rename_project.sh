#!/bin/bash

mv python_template "$1"

# change project name in all files (exclude main devcontainer.json to protect template image URL)
find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh' -not -name 'pixi.lock' -not -path './.devcontainer/devcontainer.json' \) -print0 | xargs -0 sed -i "s/python_template/$1/g"

# update just the name field in devcontainer.json
sed -i "s/\"name\": \"python_template\"/\"name\": \"$1\"/" .devcontainer/devcontainer.json

# regenerate lockfile to match renamed project
pixi update

# author name
if [ -n "$2" ]; then
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh'  \) -print0 | xargs -0 sed -i "s/Austin Gregg-Smith/$2/g"
fi

# author email
if [ -n "$3" ]; then
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh'  \) -print0 | xargs -0 sed -i "s/blooop@gmail.com/$3/g"
fi

# github username (exclude main devcontainer.json to protect template image URL)
if [ -n "$4" ]; then
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'setup_host.sh' -not -name 'update_from_template.sh' -not -path './.devcontainer/devcontainer.json' \) -print0 | xargs -0 sed -i "s/blooop/$4/g"
fi
