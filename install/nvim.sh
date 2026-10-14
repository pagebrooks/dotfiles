#!/usr/bin/env bash
# Install Neovim from a GitHub release into ~/.local.
# Usage: install/nvim.sh [tag]   tag = stable (default) | nightly | v0.12.6 ...
set -euo pipefail

tag=${1:-stable}
tar_name=nvim-linux-x86_64.tar.gz
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/$tar_name" "https://github.com/neovim/neovim/releases/download/$tag/$tar_name"

mkdir -p "$HOME/.local"
rm -rf "$HOME/.local/share/nvim/runtime" # no stale files from the previous build
tar -xzf "$tmp/$tar_name" -C "$HOME/.local" --strip-components 1
rm -rf "$tmp"
# drop the bundled parsers; nvim-treesitter builds its own under ~/.local/share/nvim/site/parser
rm -rf "$HOME/.local/lib/nvim"

echo "installed $("$HOME/.local/bin/nvim" --version | head -1) from tag '$tag'"
