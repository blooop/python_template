#! /bin/bash
set -euo pipefail

# Sets up docker, the NVIDIA Container Toolkit, git-lfs, pixi and uv, which are used
# to clone and set up docker containers.
#
# Tested on Ubuntu 22.04 / 24.04 / 26.04.

if [ "${EUID}" -eq 0 ]; then
  echo "Do not run this script as root / with sudo; it calls sudo itself where needed." >&2
  exit 1
fi

# Keep a sudo timestamp alive so the script does not stall halfway through.
sudo -v

# ---------------------------------------------------------------------------
# DOCKER
# Adapted from the official install instructions:
# https://docs.docker.com/engine/install/ubuntu/
# ---------------------------------------------------------------------------

# Remove distro/podman packages that conflict with docker-ce.
# `apt-get remove` on a package that is not installed is a no-op, so this is safe.
sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# shellcheck disable=SC1091
UBUNTU_CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"

# Docker does not always publish a suite on release day. If this release is not
# there yet, fall back to the most recent suite that is.
if ! curl -fsSL -o /dev/null "https://download.docker.com/linux/ubuntu/dists/${UBUNTU_CODENAME}/Release"; then
  echo "WARNING: Docker has no apt suite for '${UBUNTU_CODENAME}' yet; falling back to 'noble'." >&2
  UBUNTU_CODENAME=noble
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  ${UBUNTU_CODENAME} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# END OFFICIAL DOCKER INSTALL

# Allow the current user to talk to the docker socket without sudo.
# docker-ce already creates the group, so only create it if it is somehow missing.
getent group docker > /dev/null || sudo groupadd docker
sudo usermod -aG docker "$USER"

# ---------------------------------------------------------------------------
# NVIDIA CONTAINER TOOLKIT
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
# Note: the old `nvidia-docker2` package is deprecated and is NOT needed.
# ---------------------------------------------------------------------------

if command -v nvidia-smi > /dev/null && nvidia-smi -L > /dev/null 2>&1; then
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
    sudo gpg --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
else
  echo "No working NVIDIA driver detected (nvidia-smi failed); skipping NVIDIA Container Toolkit."
  echo "Install a driver first, e.g. 'sudo ubuntu-drivers install', reboot, then re-run this script."
fi

sudo apt-get install -y git-lfs

# Install rocker and rocker extensions which are used to launch the devcontainer
# pip install rocker off-your-rocker git+https://github.com/blooop/deps_rocker

# ---------------------------------------------------------------------------
# SMOKE TESTS
# The `docker` group membership added above does not apply to the current shell
# until the user logs out and back in, so run the tests with sudo. (Ubuntu 26.04
# removed `sg` and `newgrp`, so those are not an option.)
# ---------------------------------------------------------------------------

echo "testing docker install"
sudo docker run --rm hello-world

if command -v nvidia-ctk > /dev/null; then
  echo "testing nvidia docker install"
  # Plain ubuntu image matching the host release: the toolkit injects nvidia-smi
  # and the driver libraries from the host, so this avoids pinning a CUDA version.
  # shellcheck disable=SC1091
  TEST_IMAGE="ubuntu:$(. /etc/os-release && echo "$VERSION_ID")"
  sudo docker run --rm --gpus all "${TEST_IMAGE}" nvidia-smi || \
    echo "WARNING: GPU container test failed."
fi

# INSTALL PIXI
curl -fsSL https://pixi.sh/install.sh | bash
# shellcheck disable=SC2016
grep -qF 'pixi completion --shell bash' ~/.bashrc || \
  echo 'eval "$(pixi completion --shell bash)"' >> ~/.bashrc

# INSTALL UV
curl -LsSf https://astral.sh/uv/install.sh | sh

echo
echo "Done. Log out and back in (or reboot) so your 'docker' group membership applies"
echo "to every new shell, and so pixi/uv are on your PATH."
