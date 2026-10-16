#!/usr/bin/env bash
# Renders the whole status-right chip for the pane whose path is $1:
#
#   clean / not a repo   " ~/projects/Infrastructure [develop] "   dark on Dracula green
#   dirty working tree   " ~/projects/Infrastructure [develop] "   dark on Dracula orange
#
# The chip is emitted here in full -- opening style, path, branch and the closing
# #[default] -- because the background has to depend on the dirty check, and
# status-right is expanded before this script runs. The path is shortened with $HOME
# as ~.
#
# The path is bold and the branch #[nobold], so the branch reads lighter within the
# same block. tmux accepts any attribute prefixed with "no" to turn it off.
#
# Emit #[default] only at the very end; anywhere earlier it resets to the bar's own
# background and splits the block in two.
path="$1"
short="${path/#$HOME/\~}"

bg='#50fa7b'  # Dracula green
fg='#282a36'  # Dracula background, dark text on the light chip
branch=""

if cd "$path" 2>/dev/null; then
  branch=$(git branch --show-current 2>/dev/null)
  # Dirty only counts on a named branch: a detached HEAD shows neither a branch nor
  # the orange. To flag dirty detached worktrees too, drop the [ -n "$branch" ] test.
  if [ -n "$branch" ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    bg='#ffb86c'  # Dracula orange
  fi
fi

if [ -n "$branch" ]; then
  printf '#[bg=%s]#[fg=%s]#[bold] %s#[nobold] [%s] #[default]' "$bg" "$fg" "$short" "$branch"
else
  printf '#[bg=%s]#[fg=%s]#[bold] %s #[default]' "$bg" "$fg" "$short"
fi
