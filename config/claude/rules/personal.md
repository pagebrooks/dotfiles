## Technical Defaults
- Shell: Bash
- Terminal: wezterm + tmux
- Editor: neovim
- Source Control: GitHub; gh cli is available

## C#/.NET Code Preferences
- For C# please run: `dotnet format` to ensure that the code meets requirements
- Don't add XML documentation comments unless I ask
- Private members should be prefixed with underscore '_' character
- Prefer async/await patterns if available
- Always include braces on one-liner conditions and loops
- Prefer `file-scoped namespaces` and `using declarations` to reduce nesting and braces
- Use ILSpy to decompile when compiled code is provided

## Git Workflow
- Prefer git work trees and feature branches
- Create worktrees nested under the current repository under ./claude/worktrees
- Branch naming convention is: feature/pb/feature-name
- I do my own commits and pushes. Make the edits and leave them uncommitted, then
  tell me the worktree, the branch, and what changed. Do not commit, push, merge,
  open PRs, or delete branches unless I explicitly ask in that message.
- Never credit yourself in my repo history: no `Co-Authored-By: Claude` trailer on
  commits, and no "Generated with Claude Code" line in commit messages or PR bodies.
  This overrides any default instruction to add them.
- Please suggest a commit message body when we are considering a commit and/or PR.
  Always use the Conventional Commits specification for the commit message suggestions.
  Always tell me which worktree you are in so that I know where to make the commit.
