#!/usr/bin/env bash
# Symlink this repo's files into $HOME. Safe to re-run: links that are already right are skipped,
# and anything real that is in the way is moved to <path>.bak-<timestamp>.
set -euo pipefail

dotfiles=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
stamp=$(date +%Y%m%d-%H%M%S)

link() { # link <repo-relative source> <absolute target>
    local src="$dotfiles/$1" dst="$2"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$src" ]; then
        echo "ok      $dst"
        return
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak-$stamp"
        echo "backup  $dst -> $dst.bak-$stamp"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "linked  $dst -> $src"
}

# git reads ~/.config/git/config as well as ~/.gitconfig, so an old one there would layer over the link
if [ -f "$HOME/.config/git/config" ] && [ ! -L "$HOME/.config/git/config" ]; then
    mv "$HOME/.config/git/config" "$HOME/.config/git/config.bak-$stamp"
    echo "backup  $HOME/.config/git/config -> $HOME/.config/git/config.bak-$stamp (move anything you need into ~/.gitconfig.local)"
fi

link home/bashrc             "$HOME/.bashrc"
link home/gitconfig          "$HOME/.gitconfig"
link home/tmux.conf          "$HOME/.tmux.conf"
link home/wezterm.lua        "$HOME/.wezterm.lua"
link config/nvim             "$HOME/.config/nvim"      # whole dir: vim.pack rewrites the lockfile in place
link config/tmux             "$HOME/.config/tmux"
link config/git/ignore       "$HOME/.config/git/ignore"
link config/mise/config.toml "$HOME/.config/mise/config.toml"

[ -f "$HOME/.bashrc.local" ] || echo "note: no ~/.bashrc.local; create it for secrets and machine-specific settings"
[ -f "$HOME/.gitconfig.local" ] || echo "note: no ~/.gitconfig.local; create it with [user] email + signingkey and [credential] helpers"
