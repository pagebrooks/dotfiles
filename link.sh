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
link home/inputrc            "$HOME/.inputrc"
link config/nvim             "$HOME/.config/nvim"      # whole dir: vim.pack rewrites the lockfile in place
link config/tmux             "$HOME/.config/tmux"
link config/git/ignore       "$HOME/.config/git/ignore"
link config/mise/config.toml "$HOME/.config/mise/config.toml"
link config/claude/rules/personal.md "$HOME/.claude/rules/personal.md" # Claude Code loads ~/.claude/rules/*.md next to ~/.claude/CLAUDE.md
link config/claude/statusline.sh     "$HOME/.claude/statusline.sh"      # settings.json statusLine runs it
link config/claude/hooks             "$HOME/.claude/hooks"              # settings.json PostToolUse hook: nvim follows Claude

# ~/.claude/settings.json stays a per-machine file because Claude Code rewrites it (/config, /model);
# only the statusLine key and the nvim-follow hook are set from here. cat > keeps the file's permissions.
settings="$HOME/.claude/settings.json"
statusline_cmd='~/.claude/statusline.sh'
hook_cmd='~/.claude/hooks/nvim-follow.sh'
hook_matcher='EnterWorktree|ExitWorktree|Edit|Write|MultiEdit|NotebookEdit'
if ! command -v jq >/dev/null; then
    echo "note: jq missing (install/deps.sh); set statusLine and the PostToolUse hook in $settings by hand"
else
    [ -f "$settings" ] || echo '{}' > "$settings"
    if [ "$(jq -r '.statusLine.command // empty' "$settings")" = "$statusline_cmd" ]; then
        echo "ok      statusLine in $settings"
    else
        tmp=$(mktemp)
        jq --arg cmd "$statusline_cmd" '.statusLine = { type: "command", command: $cmd }' "$settings" > "$tmp"
        cat "$tmp" > "$settings"
        rm -f "$tmp"
        echo "set     statusLine in $settings -> $statusline_cmd"
    fi
    # added once; any other hooks already in the file are left alone
    if [ "$(jq -r --arg cmd "$hook_cmd" '[.hooks.PostToolUse[]?.hooks[]? | select(.command == $cmd)] | length' "$settings")" != "0" ]; then
        echo "ok      nvim-follow hook in $settings"
    else
        tmp=$(mktemp)
        jq --arg cmd "$hook_cmd" --arg m "$hook_matcher" \
            '.hooks.PostToolUse = ((.hooks.PostToolUse // []) + [{ matcher: $m, hooks: [{ type: "command", command: $cmd, async: true }] }])' \
            "$settings" > "$tmp"
        cat "$tmp" > "$settings"
        rm -f "$tmp"
        echo "set     nvim-follow hook in $settings -> $hook_cmd"
    fi
fi

[ -f "$HOME/.bashrc.local" ] || echo "note: no ~/.bashrc.local; create it for secrets and machine-specific settings"
[ -f "$HOME/.gitconfig.local" ] || echo "note: no ~/.gitconfig.local; create it with [user] email + signingkey and [credential] helpers"
