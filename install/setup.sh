#!/bin/bash

set -x

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_CONFIG_DIR="$REPO_ROOT/stow"

sudo apt update
sudo apt upgrade
sudo apt install -y \
     htop \
     bc \
     curl \
     git \
     jq \
     gh \
     ripgrep \
     tldr \
     locate \
     neofetch \
     uuid

bash nvim-nightly/install.sh
bash wezterm/install.sh
bash claude-code/install.sh