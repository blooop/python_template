#! /bin/bash
set -e

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #gets the current directory

#move to the project root folder
cd "$SCRIPT_DIR"/..

git submodule update --init --recursive

CONTAINER_NAME=${PWD##*/}  
# CONTAINER_NAME="${PWD##*/}_$(date +%Y-%m-%d_%H-%M-%S)"  

echo "stopping existing container" "$CONTAINER_NAME" 
# docker stop "$CONTAINER_NAME" || true 
docker rename "$CONTAINER_NAME" "${CONTAINER_NAME}_$(date +%Y-%m-%d_%H-%M-%S)" || true 

CONTAINER_HEX=$(printf $CONTAINER_NAME | xxd -p | tr '\n' ' ' | sed 's/\\s//g' | tr -d ' ');

#!/bin/bash

if ! dpkg -l | grep -q python3-venv; then
    echo "python3-venv is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y python3-venv
else
    echo "python3-venv is already installed."
fi

# Define the directory for the virtual environment
VENV_DIR="venv"

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
    echo "Activating the virtual environment..."
    source $VENV_DIR/bin/activate
    echo "Installing deps rocker..."
    pip install deps-rocker
    echo "Virtual environment setup and deps rocker installation complete."
else
    echo "Virtual environment already exists in $VENV_DIR."
    echo "Activating the existing virtual environment..."
    source $VENV_DIR/bin/activate
fi

# Run the rocker command with the specified parameters
rocker --nvidia --x11 --user --pull --git --image-name "$CONTAINER_NAME" --name "$CONTAINER_NAME" --volume "${PWD}":/workspaces/"${CONTAINER_NAME}":Z --env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR --volume $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR --privileged --port 9876 --deps --oyr-run-arg " --detach" minedojo/minedojo:latest "$@" 

# 
# https://github.com/rerun-io/rerun/issues/6835
# Thanks for your instructions, I made significant progress in running rerun from a docker after adding:

# `libgtk-3-dev libxkbcommon-x11-0 vulkan-tools` from your post and after adding `mesa-vulkan-drivers` I was able to load the window.

# It loads now, but is using the software renderer and still has some warnings:

# ```
# [2024-08-16T17:48:59Z WARN  wgpu_hal::gles::egl] No config found!
# [2024-08-16T17:48:59Z WARN  wgpu_hal::gles::egl] EGL says it can present to the window but not natively
# [2024-08-16T17:48:59Z WARN  re_renderer::context] Bad software rasterizer detected - expect poor performance and crashes. See: https://www.rerun.io/docs/getting-started/troubleshooting#graphics-issues
# ```

deactivate

#this follows the same convention as if it were opened by a vscode devcontainer
code --folder-uri vscode-remote://attached-container+"$CONTAINER_HEX"/workspaces/"${CONTAINER_NAME}"
