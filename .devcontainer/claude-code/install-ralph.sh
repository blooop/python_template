#!/bin/sh
set -eu

# Ralph installation script - runs after pixi install
# This ensures nodejs and tmux are available from pixi

echo "========================================="
echo "Installing Ralph for Claude Code"
echo "========================================="

TARGET_HOME="${HOME:-/home/vscode}"
RALPH_HOME="$TARGET_HOME/.ralph"

# Check if already installed
if [ -d "$RALPH_HOME" ] && [ -x "$TARGET_HOME/.local/bin/ralph" ]; then
    echo "Ralph is already installed"
    exit 0
fi

# Verify nodejs is available (from pixi)
if ! command -v node >/dev/null 2>&1; then
    # Try to activate pixi environment
    if [ -f ".pixi/envs/default/bin/node" ]; then
        export PATH="$PWD/.pixi/envs/default/bin:$PATH"
    fi
fi

if ! command -v node >/dev/null 2>&1; then
    echo "Warning: nodejs not found. Ralph installation may fail."
    echo "Make sure 'nodejs' is in your pixi dependencies."
fi

# Clone ralph-claude-code to a temporary location
TMP_DIR=$(mktemp -d)
echo "Cloning ralph-claude-code repository..."

if ! git clone --depth 1 https://github.com/frankbria/ralph-claude-code.git "$TMP_DIR/ralph-claude-code"; then
    echo "Error: Failed to clone ralph-claude-code repository" >&2
    rm -rf "$TMP_DIR"
    exit 1
fi

# Run install script
echo "Running Ralph install script..."
cd "$TMP_DIR/ralph-claude-code"

# Set PATH to include pixi's nodejs before running install
if [ -f "$OLDPWD/.pixi/envs/default/bin/node" ]; then
    export PATH="$OLDPWD/.pixi/envs/default/bin:$PATH"
fi

./install.sh

# Cleanup
rm -rf "$TMP_DIR"

# Verify installation
if [ -x "$TARGET_HOME/.local/bin/ralph" ]; then
    echo "========================================="
    echo "Ralph installed successfully!"
    echo "========================================="
    echo ""
    echo "Ralph commands available:"
    echo "  ralph --monitor    Start autonomous development with monitoring"
    echo "  ralph-setup        Create a new Ralph project"
    echo "  ralph-import       Import PRD to Ralph project"
    echo ""
else
    echo "Warning: Ralph installation may have failed" >&2
    exit 1
fi
