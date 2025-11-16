#!/bin/bash
# Common setup functions for pixi-based development environments
# Can be sourced by various setup scripts (SessionStart, devcontainer, etc.)

# Install pixi if not already installed
install_pixi() {
    if ! command -v pixi &> /dev/null; then
        echo "Installing pixi..."
        curl -fsSL https://pixi.sh/install.sh | bash

        # Add pixi to PATH for current session
        export PATH="$HOME/.pixi/bin:$PATH"

        # Source bashrc to get pixi in PATH (if bashrc was updated)
        [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

        echo "Pixi installed successfully"
    else
        echo "Pixi already installed"
    fi

    # Ensure pixi is in PATH for this session
    export PATH="$HOME/.pixi/bin:$PATH"
}

# Install project dependencies using pixi
install_dependencies() {
    echo "Installing project dependencies..."
    pixi install
}

# Setup pre-commit hooks
setup_pre_commit() {
    echo "Setting up pre-commit hooks..."
    pixi run pre-commit install || echo "Pre-commit installation skipped (optional)"
}

# Setup git merge driver for lockfiles
setup_git_merge_driver() {
    echo "Configuring git merge driver..."
    pixi run setup-git-merge-driver || true
}

# Full environment setup
setup_environment() {
    install_pixi
    install_dependencies
    setup_pre_commit
    setup_git_merge_driver
}
