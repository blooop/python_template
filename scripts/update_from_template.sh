#!/bin/bash
set -euo pipefail

TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/blooop/python_template.git}"
BRANCH="feature/update_from_template"

# Ensure clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Error: working tree is dirty. Commit or stash changes first."
    exit 1
fi

git config --global pull.rebase false

# Setup merge driver for pixi.lock (idempotent)
git config merge.ourslock.driver true

# Add template remote (remove first if leftover from a failed run)
git remote remove template 2>/dev/null || true
git remote add template "$TEMPLATE_REPO"

cleanup() {
    git remote remove template 2>/dev/null || true
}
trap cleanup EXIT

git fetch template main

# Check if there are any changes to merge
if git diff HEAD...template/main --quiet 2>/dev/null; then
    echo "No changes from template. Already up to date."
    exit 0
fi

# Get to a clean main/master
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"

# Create or reset the update branch
git checkout -B "$BRANCH"

# Merge template changes — this is a real git merge so:
#  - 3-way merge at line level across ALL files
#  - git remembers the merge base, so conflicts only appear once
#  - --allow-unrelated-histories is needed for the first merge, harmless after
if ! git merge template/main --allow-unrelated-histories -m 'feat: pull changes from remote template'; then
    echo ""
    echo "============================================="
    echo "  Merge conflicts detected — resolve them,"
    echo "  then run: pixi update && git add pixi.lock"
    echo "  and commit to finish the merge."
    echo "============================================="
    exit 1
fi

# Resolve pixi.lock: keep ours, then regenerate from merged pyproject.toml
git checkout --ours pixi.lock 2>/dev/null || true
pixi update
git add pixi.lock
git diff --cached --quiet || git commit -m 'chore: update pixi.lock after template merge'

git push --set-upstream origin "$BRANCH"

# Create a PR if gh is available and no open PR exists
if command -v gh &>/dev/null; then
    EXISTING=$(gh pr list --head "$BRANCH" --state open --json number -q '.[0].number' 2>/dev/null || true)
    if [ -z "$EXISTING" ]; then
        gh pr create \
            --title "feat: sync updates from template repo" \
            --body "Automated pull of changes from [$TEMPLATE_REPO]($TEMPLATE_REPO) using \`git merge\`." \
            --fill 2>/dev/null || echo "PR creation skipped (gh not authenticated or not a GitHub repo)."
    else
        echo "PR #$EXISTING already open for $BRANCH."
    fi
fi

git checkout "$DEFAULT_BRANCH"
echo "Done. Review the PR for branch $BRANCH."
