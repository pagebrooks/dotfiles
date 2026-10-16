#!/usr/bin/env bash
# Claude Code status line: the session's current directory, $HOME shown as ~, in the prompt's Dracula cyan.
# Claude Code pipes session JSON on stdin and shows whatever this prints below the input box.
dir=$(jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
[ -n "$dir" ] || dir=$PWD
printf '\033[38;2;139;233;253m%s\033[0m' "${dir/#$HOME/\~}"
