#!/usr/bin/env bash
# tree-sitter CLI: required by nvim-treesitter (main branch) to build parsers.
set -euo pipefail

ver=${1:-$(curl -fsSL https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest | grep -oP '"tag_name":\s*"\K[^"]+')}
tmp=$(mktemp -d)
curl -fsSL -o "$tmp/tree-sitter.gz" "https://github.com/tree-sitter/tree-sitter/releases/download/$ver/tree-sitter-linux-x64.gz"
gunzip "$tmp/tree-sitter.gz"
mkdir -p "$HOME/.local/bin"
install -m 755 "$tmp/tree-sitter" "$HOME/.local/bin/tree-sitter"
rm -rf "$tmp"
echo "installed tree-sitter $("$HOME/.local/bin/tree-sitter" --version) to ~/.local/bin"
