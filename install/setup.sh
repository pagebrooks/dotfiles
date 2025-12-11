#!/bin/bash

set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_CONFIG_DIR="$REPO_ROOT/stow"

sudo apt update
sudo apt upgrade

sudo apt install -y \
    alsa-utils \
    stow \
    htop \
    bc \
    make \
    build-essential \
    curl \
    firefox-esr \
    git \
    jq \
    gh \
    ripgrep \
    tldr \
    locate \
    neofetch \
    uuid \

sudo updatedb


bash install/nvim-nightly/install.sh
bash install/claude-code/install.sh

# Stow all managed configs (bash, nvim)
bash "$SCRIPT_DIR/stow-all.sh"
