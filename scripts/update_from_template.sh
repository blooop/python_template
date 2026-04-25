#! /bin/bash
set -eo pipefail

TEMPLATE_URL="${TEMPLATE_URL:-https://github.com/blooop/python_template.git}"
BRANCH="${BRANCH:-feature/update_from_template}"

git config pull.rebase false
git remote remove template 2>/dev/null || true
git remote add template "$TEMPLATE_URL"
git fetch --all
git checkout main && git pull origin main
git checkout -B "$BRANCH"
git merge template/main --allow-unrelated-histories -m 'feat: pull changes from remote template'
git checkout --ours pixi.lock 2>/dev/null || true

# regenerate lockfile to match merged pyproject.toml
pixi update
git add pixi.lock
git diff --cached --quiet || git commit -m 'chore: update pixi.lock after template merge'

git remote remove template
git push --set-upstream origin "$BRANCH"
git checkout main
