#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

command -v stow >/dev/null 2>&1 || { echo "GNU Stow is required."; exit 1; }

PACKAGES=(bash nvim wezterm)

for pkg in "${PACKAGES[@]}"; do
  if [ -d "$REPO_ROOT/$pkg" ]; then
    echo "Stowing $pkg from $REPO_ROOT into $HOME"

    # Handle common conflicts by backing up existing non-symlink targets
    case "$pkg" in
      bash)
        target="$HOME/.bashrc"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          echo "Backing up existing $target to $target.bak"
          mv "$target" "$target.bak"
        fi
        ;;
    esac

    stow -D -t "$HOME" -d "$REPO_ROOT" "$pkg" || true
    stow -t "$HOME" -d "$REPO_ROOT" "$pkg"
  else
    echo "Package $pkg not found at $REPO_ROOT/$pkg; skipping." >&2
  fi
done

echo "Stow completed."
