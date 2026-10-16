#!/usr/bin/env bash
# Project launcher: pick a directory under ~/projects (or one of its Claude worktrees) and switch to a
# tmux session for it. First use creates the session with the two-pane layout: claude on the left,
# nvim on the right with the focus. Later uses just switch, so a session per project accumulates state all day.
#
# tmux.conf binds it to prefix + f in a popup. Usage: project.sh [dir | --list]
#   PROJECTS       root to scan (default ~/projects)
#   PROJECT_AGENT  command for the left pane (default claude; e.g. "claude -c" to resume the last session)
#   PROJECT_EDITOR command for the right pane (default nvim)
set -euo pipefail
PATH="$HOME/.fzf/bin:$HOME/.local/bin:$PATH" # popups run a non-interactive shell: no .bashrc, no fzf on PATH

root="${PROJECTS:-$HOME/projects}"
editor="${PROJECT_EDITOR:-nvim}"
agent="${PROJECT_AGENT:-claude}"

candidates() { # top-level projects, then any Claude worktrees inside them
    {
        find "$root" -mindepth 1 -maxdepth 1 -type d -not -name '.*'
        find "$root" -mindepth 4 -maxdepth 4 -type d -path '*/.claude/worktrees/*'
    } 2>/dev/null | sort
}

session_name() { # repo -> repo; repo/.claude/worktrees/wt -> repo-wt. tmux forbids . and : in names.
    local dir=$1 name
    case $dir in
        */.claude/worktrees/*) name="$(basename "${dir%/.claude/worktrees/*}")-$(basename "$dir")" ;;
        *) name=$(basename "$dir") ;;
    esac
    printf '%s' "${name//[.:]/_}"
}

if [ "${1:-}" = "--list" ]; then
    candidates
    exit 0
fi

if [ -n "${1:-}" ]; then
    dir=$(cd "$1" && pwd -P)
else
    open=$(tmux list-sessions -F '#S' 2>/dev/null || true)
    # one line per project: "<marker> <~/path>\t<full path>"; fzf shows the first field, we keep the second
    dir=$(candidates | while read -r d; do
        mark=" "
        grep -qx "$(session_name "$d")" <<<"$open" && mark="●"
        printf '%s %s\t%s\n' "$mark" "${d/#$HOME/\~}" "$d"
    done | fzf --prompt='project> ' --reverse --no-info --delimiter='\t' --with-nth=1 \
        --preview='git -C {2} log --oneline -8 2>/dev/null; echo; ls -1 {2}' --preview-window='right:45%' \
        | cut -f2)
    [ -n "$dir" ] || exit 0
fi

name=$(session_name "$dir")
if ! tmux has-session -t "=$name" 2>/dev/null; then
    tmux new-session -d -s "$name" -c "$dir" -n main
    tmux send-keys -t "=$name:main" "$agent" C-m
    tmux split-window -h -t "=$name:main" -c "$dir" # the new pane, on the right, becomes active
    tmux send-keys -t "=$name:main" "$editor" C-m
fi

if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "=$name"
else
    exec tmux attach-session -t "=$name"
fi
