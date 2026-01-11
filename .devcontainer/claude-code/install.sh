#!/bin/sh
set -eu

# Claude Code CLI Local Feature Install Script
# Installs Claude Code via pixi and sets up configuration directories

# Function to install pixi if not found
install_pixi() {
    echo "Installing pixi..."

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac

    # Download and install pixi
    curl -fsSL "https://github.com/prefix-dev/pixi/releases/latest/download/pixi-${ARCH}-unknown-linux-musl" -o /usr/local/bin/pixi
    chmod +x /usr/local/bin/pixi

    echo "pixi installed successfully"
    pixi --version
}

# Function to install Claude Code CLI via pixi
install_claude_code() {
    echo "Installing Claude Code CLI via pixi..."

    # Install pixi if not available
    if ! command -v pixi >/dev/null; then
        install_pixi
    fi

    # Determine target user for pixi global install
    local target_user="${_REMOTE_USER:-vscode}"
    local target_home="${_REMOTE_USER_HOME:-/home/${target_user}}"

    # Install with pixi global from blooop channel
    # Run as target user so it installs to their home directory
    if [ "$(id -u)" -eq 0 ] && [ "$target_user" != "root" ]; then
        su - "$target_user" -c "pixi global install --channel https://prefix.dev/blooop claude-shim"
    else
        pixi global install --channel https://prefix.dev/blooop claude-shim
    fi

    # Add pixi paths to user's profile if not already there
    local profile="$target_home/.profile"
    local pixi_path_line='export PATH="$HOME/.pixi/envs/claude-shim/bin:$HOME/.pixi/bin:$PATH"'
    if [ -f "$profile" ] && ! grep -q "\.pixi/envs/claude-shim/bin" "$profile"; then
        echo "$pixi_path_line" >> "$profile"
    elif [ ! -f "$profile" ]; then
        echo "$pixi_path_line" > "$profile"
        chown "$target_user:$target_user" "$profile" 2>/dev/null || true
    fi

    # Verify installation by checking the binary exists
    local pixi_bin_path="$target_home/.pixi/bin"
    local claude_bin="$pixi_bin_path/claude"
    if [ -x "$claude_bin" ]; then
        echo "Claude Code CLI installed successfully!"
        "$claude_bin" --version
        return 0
    else
        echo "ERROR: Claude Code CLI installation failed! Binary not found at $claude_bin"
        return 1
    fi
}

# Function to create Claude configuration directories
create_claude_directories() {
    echo "Creating Claude configuration directories..."

    # Determine the target user's home directory
    local target_user="${_REMOTE_USER:-vscode}"
    local target_home="${_REMOTE_USER_HOME:-/home/${target_user}}"

    # Be defensive: if the resolved home does not exist, fall back
    if [ ! -d "$target_home" ]; then
        if [ -n "${HOME:-}" ] && [ -d "$HOME" ]; then
            echo "Warning: target_home '$target_home' does not exist, falling back to \$HOME: $HOME" >&2
            target_home="$HOME"
        elif [ -d "/home/${target_user}" ]; then
            echo "Warning: target_home '$target_home' does not exist, falling back to /home/${target_user}" >&2
            target_home="/home/${target_user}"
        else
            echo "Error: No suitable home directory found for '${target_user}'." >&2
            exit 1
        fi
    fi

    echo "Target home directory: $target_home"
    echo "Target user: $target_user"

    # Create the main .claude directory and subdirectories
    mkdir -p "$target_home/.claude"
    mkdir -p "$target_home/.claude/agents"
    mkdir -p "$target_home/.claude/commands"
    mkdir -p "$target_home/.claude/hooks"

    # Create empty config files if they don't exist
    if [ ! -f "$target_home/.claude/.credentials.json" ]; then
        echo "{}" > "$target_home/.claude/.credentials.json"
        chmod 600 "$target_home/.claude/.credentials.json"
    fi

    if [ ! -f "$target_home/.claude/.claude.json" ]; then
        echo "{}" > "$target_home/.claude/.claude.json"
        chmod 600 "$target_home/.claude/.claude.json"
    fi

    # Set proper ownership
    if [ "$(id -u)" -eq 0 ]; then
        chown -R "$target_user:$target_user" "$target_home/.claude" || true
    fi

    echo "Claude directories created successfully"
}

# Main script
main() {
    echo "========================================="
    echo "Activating feature 'claude-code' (local)"
    echo "========================================="

    # Determine target paths
    local target_user="${_REMOTE_USER:-vscode}"
    local target_home="${_REMOTE_USER_HOME:-/home/${target_user}}"
    local claude_bin="$target_home/.pixi/bin/claude"

    # Install Claude Code CLI
    if [ -x "$claude_bin" ]; then
        echo "Claude Code CLI is already installed"
        "$claude_bin" --version
    else
        install_claude_code || exit 1
    fi

    # Create Claude configuration directories
    create_claude_directories

    echo "========================================="
    echo "Claude Code feature activated successfully!"
    echo "========================================="
    echo ""
    echo "Configuration is stored in a Docker volume (claude-config)"
    echo "and persists between container rebuilds."
    echo ""
    echo "To authenticate, run 'claude' and follow the OAuth flow."
    echo ""
}

main
