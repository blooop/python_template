#!/bin/bash
set -eo pipefail

# Escape characters special in sed replacement strings (\, &, /)
escape_sed() { printf '%s\n' "$1" | sed 's/[\\&/]/\\&/g'; }

mv python_template "$1"

ESCAPED_1=$(escape_sed "$1")

# devpod strips separators out of the repo name to build its workspace name, so the tree
# also carries `pythontemplate` (ssh hosts, /workspaces/ paths) which the sed below would
# never match. Substitute the separator-stripped new name for it.
STRIPPED_1="${1//[_-]/}"
ESCAPED_1_STRIPPED=$(escape_sed "$STRIPPED_1")

# change project name in all files (exclude main devcontainer.json to protect template image URL)
# sed re-scans each replacement with the later expressions, so `pythontemplate` goes first: a
# stripped name can never contain an underscore, so it can never manufacture a fresh
# `python_template`. The other order breaks on a new name that itself contains
# `pythontemplate` -- `pythontemplate_fork` would come out as `pythontemplatefork_fork`.
# The first and last expressions mask the prebuilt image reference: it is the one
# `python_template` in the tree that names a real published package rather than this project,
# so renaming it yields a ghcr.io URL that 404s. It appears in the root README and in
# .devcontainer/claude-code/{README,TROUBLESHOOTING}.md, which must otherwise be renamed
# normally, so the string is protected instead of the files.
find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh' -not -name 'pixi.lock' -not -path './.devcontainer/devcontainer.json' \) -print0 | xargs -0 sed -i -e 's|blooop/python_template/devcontainer|@@IMGREF@@|g' -e "s/pythontemplate/$ESCAPED_1_STRIPPED/g" -e "s/python_template/$ESCAPED_1/g" -e 's|@@IMGREF@@|blooop/python_template/devcontainer|g'

# update just the name field in devcontainer.json
sed -i "s/\"name\": \"python_template\"/\"name\": \"$ESCAPED_1\"/" .devcontainer/devcontainer.json

# regenerate lockfile to match renamed project
pixi update

# author name
if [ -n "$2" ]; then
    ESCAPED_2=$(escape_sed "$2")
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh'  \) -print0 | xargs -0 sed -i "s/Austin Gregg-Smith/$ESCAPED_2/g"
fi

# author email
if [ -n "$3" ]; then
    ESCAPED_3=$(escape_sed "$3")
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'tasks.json' -not -name 'update_from_template.sh'  \) -print0 | xargs -0 sed -i "s/blooop@gmail.com/$ESCAPED_3/g"
fi

# github username (exclude main devcontainer.json to protect template image URL)
if [ -n "$4" ]; then
    ESCAPED_4=$(escape_sed "$4")
    find . \( -type d -name .git -prune \) -o \( -type f -not -name 'setup_host.sh' -not -name 'update_from_template.sh' -not -path './.devcontainer/devcontainer.json' \) -print0 | xargs -0 sed -i "s/blooop/$ESCAPED_4/g"
fi
