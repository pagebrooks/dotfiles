# dotfiles

bash, git, tmux, wezterm, nvim and mise config, symlinked into `$HOME`. Works on Debian 12 (personal
machine) and Ubuntu under WSL with wezterm on Windows (work machine) from the same files: bashrc and
init.lua detect WSL at runtime; per-machine values live in gitignored `.local` files.

```sh
git clone <url> ~/projects/dotfiles
cd ~/projects/dotfiles
install/deps.sh            # apt packages, fd/bat symlinks, delta, mise, fzf; on WSL also win32yank + wsl.conf
install/nvim.sh            # Neovim release into ~/.local (stable | nightly | vX.Y.Z)
install/tree-sitter-cli.sh # tree-sitter CLI; nvim-treesitter needs it to build parsers
install/roslyn.sh          # C# language server for nvim, as a dotnet tool (needs a .NET SDK)
./link.sh                  # symlinks; backs up anything real that is in the way
~/.local/bin/mise install  # go and node pinned in config/mise/config.toml
install/wezterm.sh         # optional: wezterm from its apt repo (not on WSL)
install/wezterm-windows.sh # WSL: point wezterm on Windows at home/wezterm.lua (run from this checkout)
install/claude-code.sh     # optional: Claude Code
```

`home/` maps to `~/.<name>`; `config/` maps to `~/.config/`.

Per-machine files, never committed:

- `~/.bashrc.local` — secrets and local env; sourced at the end of bashrc
- `~/.gitconfig.local` — `[user] email`, `signingkey`, `[credential]` helpers; included at the end of gitconfig
- `~/.claude/CLAUDE.md` — machine-specific Claude Code instructions (e.g. work stack and branch model); the shared
  ones are `config/claude/rules/personal.md`, linked into `~/.claude/rules/`
- `~/.claude/settings.json` — Claude Code rewrites it, so it stays per-machine; `link.sh` only sets its `statusLine`
  to `~/.claude/statusline.sh` (linked from `config/claude/statusline.sh`) and adds the PostToolUse hook below

## nvim + Claude Code in one tmux window

nvim in one pane, `claude` in the other. nvim publishes its RPC socket as the tmux pane option `@nvim_socket`;
the PostToolUse hook `config/claude/hooks/nvim-follow.sh` (linked to `~/.claude/hooks/`) finds it in Claude's
window and calls into `config/nvim/lua/claude.lua`:

- Claude enters a worktree → nvim opens a tab with `tcd` set to it (and the file you were looking at, if it
  exists there); exits → back to the tab for that directory, tabs for removed worktrees are closed
- Claude edits a file → the buffer reloads right away if open, and the file is remembered

| key | |
| :- | :- |
| `<leader>cl` | open the last file Claude edited |
| `<leader>ce` | pick from the files Claude edited |
| `<leader>cs` | type `@file ` (visual: `@file L1-L2 `) into the claude prompt, without submitting |
| `<leader>cc` | jump to the claude pane |
| `<leader>cf` / `:ClaudeFollow` | stop/start following into worktrees; edits are still remembered |

Without tmux, or with no nvim in the window, the hook does nothing.

To try the bootstrap on a clean image, see the comment at the top of `Containerfile.debian`.

WSL notes: wezterm on Windows reads `%USERPROFILE%\.wezterm.lua`, a stub that `install/wezterm-windows.sh`
writes to load `home/wezterm.lua` over `\\wsl.localhost` and open the WSL distro by default. Its paste is
`ctrl+shift+v`, so `ctrl+v` reaches nvim's visual-block mode (Windows Terminal needs `ctrl+v` unbound).
`install/deps.sh` disables `appendWindowsPath` in `/etc/wsl.conf`; bashrc re-adds `System32` so
`win32yank.exe`, `explorer.exe` and `powershell.exe` stay reachable.
