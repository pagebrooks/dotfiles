#!/usr/bin/env bash
# Project picker: fuzzy-pick a directory under ~/projects (or one of its Claude worktrees) and cd the
# calling pane into it. No new session or window: the shell you pressed the key in just changes directory.
#
# tmux.conf binds it to prefix + f in a popup. Usage: project.sh [pane]
#   pane      tmux pane to cd (tmux.conf passes #{pane_id}; popups inherit a stale TMUX_PANE from the server)
#   PROJECTS  root to scan (default ~/projects)
set -euo pipefail
PATH="$HOME/.fzf/bin:$HOME/.local/bin:$PATH" # popups run a non-interactive shell: no .bashrc, no fzf on PATH

root="${PROJECTS:-$HOME/projects}"
pane="${1:-${TMUX_PANE:-}}"

candidates() { # top-level projects, then any Claude worktrees inside them
    {
        find "$root" -mindepth 1 -maxdepth 1 -type d -not -name '.*'
        find "$root" -mindepth 4 -maxdepth 4 -type d -path '*/.claude/worktrees/*'
    } 2>/dev/null | sort
}

# one line per project: "<~/path>\t<full path>"; fzf shows the first field, we keep the second
dir=$(candidates | while read -r d; do printf '%s\t%s\n' "${d/#$HOME/\~}" "$d"; done \
    | fzf --prompt='project> ' --reverse --no-info --delimiter='\t' --with-nth=1 \
        --preview='git -C {2} log --oneline -8 2>/dev/null; echo; ls -1 {2}' --preview-window='right:45%' \
    | cut -f2)
[ -n "$dir" ] || exit 0

# The popup's shell dies with the popup, so the cd is typed into the pane's shell instead. Refuse when the
# pane is running something else (nvim, claude, ...) rather than feed it a stray "cd" line.
running=$(tmux display-message -p -t "$pane" '#{pane_current_command}')
case $running in
    bash | zsh | sh | fish) tmux send-keys -t "$pane" "cd $(printf '%q' "$dir")" C-m ;;
    *) tmux display-message "project.sh: pane is running $running, not a shell; cd skipped" ;;
esac
