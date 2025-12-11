#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_CONFIG_DIR="$REPO_ROOT/stow"

command -v stow >/dev/null 2>&1 || { echo "GNU Stow is required."; exit 1; }

PACKAGES=(bash nvim)

for pkg in "${PACKAGES[@]}"; do
  if [ -d "$STOW_CONFIG_DIR/$pkg" ]; then
    echo "Stowing $pkg from $STOW_CONFIG_DIR into $HOME"

    # Handle common conflicts by backing up existing non-symlink targets
    case "$pkg" in
      bash)
        target="$HOME/.bashrc"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Backing up existing $target to $target.bak"
          mv "$target" "$target.bak"
        fi
        ;;
      nvim)
        target_dir="$HOME/.config/nvim"
        if [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
          echo "Backing up existing $target_dir to ${target_dir}.bak"
          mv "$target_dir" "${target_dir}.bak"
        fi
        ;;
    esac

    stow -D -t "$HOME" -d "$STOW_CONFIG_DIR" "$pkg" || true
    stow -t "$HOME" -d "$STOW_CONFIG_DIR" "$pkg"
  else
    echo "Package $pkg not found at $STOW_CONFIG_DIR/$pkg; skipping." >&2
  fi
done

echo "Stow completed."
