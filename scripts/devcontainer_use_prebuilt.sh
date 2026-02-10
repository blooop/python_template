#!/bin/bash
set -euo pipefail

# Migrate devcontainer.json from local builds to a prebuilt GHCR image.
# Also attempts to make the GHCR package public.

DEVCONTAINER_JSON=".devcontainer/devcontainer.json"

# --- Resolve GitHub owner/repo from git remote ---
REMOTE_URL=$(git remote get-url origin 2>/dev/null) || {
    echo "ERROR: No git remote 'origin' found." >&2
    exit 1
}

# Handle ssh (git@github.com:owner/repo.git) and https URLs
REPO=$(echo "$REMOTE_URL" | sed -E 's#(git@github\.com:|https://github\.com/)##; s/\.git$//')

if [[ -z "$REPO" || "$REPO" != */* ]]; then
    echo "ERROR: Could not parse owner/repo from remote URL: $REMOTE_URL" >&2
    exit 1
fi

IMAGE="ghcr.io/${REPO}/devcontainer:latest"
echo "Repository: $REPO"
echo "Image:      $IMAGE"

# --- Check current state: look for an uncommented "image": line ---
if grep -qP '^\s+"image"\s*:' "$DEVCONTAINER_JSON"; then
    echo "Already using a prebuilt image. Nothing to do."
    exit 0
fi

# --- Replace the file using awk for reliable block manipulation ---
awk -v image="$IMAGE" '
    # Comment out uncommented "build" block (4-space indent open/close)
    /^    "build": \{/ { in_build=1 }
    in_build {
        sub(/^    /, "    // ")
        if (/^    \/\/ \}/) in_build=0
        print; next
    }

    # Comment out uncommented "features" block (4-space indent open/close)
    /^    "features": \{/ { in_features=1 }
    in_features {
        sub(/^    /, "    // ")
        if (/^    \/\/ \}/) in_features=0
        print; next
    }

    # Uncomment the image line and set the correct reference
    /^    \/\/ "image":/ {
        printf "    \"image\": \"%s\",\n", image
        next
    }

    { print }
' "$DEVCONTAINER_JSON" > "${DEVCONTAINER_JSON}.tmp" && mv "${DEVCONTAINER_JSON}.tmp" "$DEVCONTAINER_JSON"

echo ""
echo "Updated $DEVCONTAINER_JSON to use prebuilt image."

# --- Try to make the GHCR package public ---
echo ""
echo "Attempting to make GHCR package public..."

PACKAGE_NAME=$(echo "$REPO" | cut -d'/' -f2)
ENCODED_PACKAGE="${PACKAGE_NAME}%2Fdevcontainer"

if gh api --method PATCH "/user/packages/container/${ENCODED_PACKAGE}" -f visibility=public >/dev/null 2>&1; then
    echo "GHCR package is now public."
else
    echo "Could not set package visibility automatically."
    echo ""
    echo "To make the package public manually, either:"
    echo ""
    echo "  1. Visit: https://github.com/users/$(echo "$REPO" | cut -d'/' -f1)/packages/container/${ENCODED_PACKAGE}/settings"
    echo "     -> Danger Zone -> Change visibility -> Public"
    echo ""
    echo "  2. Run:"
    echo "     gh auth refresh -s write:packages"
    echo "     gh api --method PATCH /user/packages/container/${ENCODED_PACKAGE} -f visibility=public"
fi
