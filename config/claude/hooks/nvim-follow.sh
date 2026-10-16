#!/usr/bin/env bash
# Claude Code PostToolUse hook: tell the nvim in this tmux window what Claude just did.
#   EnterWorktree / ExitWorktree  -> nvim switches to a tab for the new directory (config/nvim/lua/claude.lua)
#   Edit / Write / MultiEdit / NotebookEdit -> nvim reloads the file if open and remembers it for <leader>cl
# Wired into ~/.claude/settings.json by link.sh. Never blocks or fails Claude: no nvim, no tmux -> exit 0.
set -u
command -v jq >/dev/null && command -v tmux >/dev/null && [ -n "${TMUX_PANE:-}" ] || exit 0

payload=$(cat)
tool=$(jq -r '.tool_name // empty' <<<"$payload")
cwd=$(jq -r '.cwd // empty' <<<"$payload")
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$payload")

# mark this pane so nvim's <leader>cs / <leader>cc can find it whatever the process is called
tmux set -p -t "$TMUX_PANE" @claude_pane 1 2>/dev/null

# the nvim socket: first one published on a pane in this window, else anywhere in the session
sock=$(tmux list-panes -t "$TMUX_PANE" -F '#{@nvim_socket}' 2>/dev/null | grep -m1 .)
[ -n "$sock" ] || sock=$(tmux list-panes -s -t "$TMUX_PANE" -F '#{@nvim_socket}' 2>/dev/null | grep -m1 .)
[ -n "$sock" ] && [ -S "$sock" ] || exit 0

vimstr() { printf "'%s'" "${1//\'/\'\'}"; } # single-quoted Vim string literal

case $tool in
    EnterWorktree) expr="v:lua.Claude.enter($(vimstr "$cwd"))" ;;
    ExitWorktree)  expr="v:lua.Claude.exit($(vimstr "$cwd"))" ;;
    Edit|Write|MultiEdit|NotebookEdit)
        [ -n "$file" ] || exit 0
        expr="v:lua.Claude.edited($(vimstr "$file"))" ;;
    *) exit 0 ;;
esac

timeout 3 nvim --server "$sock" --remote-expr "$expr" >/dev/null 2>&1
exit 0
