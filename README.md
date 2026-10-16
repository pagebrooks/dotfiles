# dotfiles

bash, git, tmux, wezterm, nvim, mise and Claude Code config, symlinked into `$HOME`. Works on Debian 12
(personal laptop) and Ubuntu under WSL with wezterm on Windows (work machine) from the same files: bashrc
and init.lua detect WSL at runtime; per-machine values live in gitignored `.local` files.

## Install

```sh
git clone https://github.com/pagebrooks/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
install/deps.sh            # apt packages, fd/bat symlinks, delta, mise, fzf; on WSL also win32yank + wsl.conf
install/nvim.sh            # Neovim release into ~/.local (stable | nightly | vX.Y.Z)
install/tree-sitter-cli.sh # tree-sitter CLI; nvim-treesitter needs it to build parsers
./link.sh                  # symlinks; backs up anything real that is in the way
~/.local/bin/mise install  # go and node pinned in config/mise/config.toml
install/roslyn.sh          # C# language server for nvim; run where `dotnet` resolves (a project with a mise pin)
install/wezterm.sh         # optional: wezterm from its apt repo (not on WSL)
install/wezterm-windows.sh # WSL: point wezterm on Windows at home/wezterm.lua (run from this checkout)
install/claude-code.sh     # optional: Claude Code
```

Go tooling for nvim is not scripted yet. After `mise install`:

```sh
go install golang.org/x/tools/gopls@latest mvdan.cc/gofumpt@latest honnef.co/go/tools/cmd/staticcheck@latest
mise reshim   # mise sets GOBIN inside its Go install, so the shims are what put these on PATH
```

Then open a new terminal (bashrc execs tmux) and start nvim once; `vim.pack` clones the plugins at the
lockfile revisions and nvim-treesitter builds the parsers.

## Layout

- `home/<name>` → `~/.<name>`: `bashrc`, `inputrc`, `gitconfig`, `tmux.conf`, `wezterm.lua`
- `config/<dir>` → `~/.config/<dir>`: `nvim/` (whole dir, so vim.pack keeps the lockfile in the repo),
  `tmux/` (status bar scripts), `git/ignore`, `mise/config.toml`
- `config/claude/` → `~/.claude/`: `rules/personal.md`, `statusline.sh`, `hooks/`
- `install/`: one script per tool that is not in Debian's packages. `link.sh` is the only script a new machine
  needs after the installs; it is safe to re-run.

Per-machine files, never committed:

- `~/.bashrc.local` — secrets and local env; sourced at the end of bashrc
- `~/.gitconfig.local` — `[user] email`, `signingkey`, `[credential]` helpers; included at the end of gitconfig
- `~/.claude/CLAUDE.md` — machine-specific Claude Code instructions (e.g. work stack and branch model); the shared
  ones are `config/claude/rules/personal.md`
- `~/.claude/settings.json` — Claude Code rewrites it, so it stays per-machine; `link.sh` only sets its `statusLine`
  and adds the nvim-follow PostToolUse hook, each once

Claude Code creates its worktrees for this repo under `.claude/worktrees/`, which git does not track.

## What you get

- **Shell**: every new terminal tab execs its own tmux session. The prompt is the directory and `❯`, red after a
  failed command, with `user@host` only over SSH; branch and dirty state are in the tmux bar instead.
  History is unlimited, timestamped, and shared across panes as you type. `cd <project>` works from anywhere
  via `CDPATH`. `EDITOR` is nvim. Aliases: `vi`/`vim`, `glol`, `myip`, `weather`, `myprofile`.
- **git**: SSH-signed commits, `delta` as pager, `pull.rebase`, `push.autoSetupRemote`, `main` as default branch.
  Identity and credential helper come from `~/.gitconfig.local`.
- **tmux**: prefix `C-a`, `|` and `-` split in the current path, vi copy mode. `Ctrl+h/j/k/l` move between
  panes and nvim splits alike (vim-tmux-navigator); the key goes to the program instead when there is no pane
  in that direction, and `Ctrl+j`/`Ctrl+k` always reach Claude Code's input. `prefix Ctrl+l` sends a real
  Ctrl+L. The status bar shows the active pane's path and branch (orange when the tree is dirty), battery
  on laptops, date and the weather. `prefix f` opens the project launcher: a popup listing every directory
  under `~/projects` and every Claude worktree inside them (`●` marks ones with a session). Picking one
  switches to its session, creating it on first use with `claude` on the left and nvim on the right. Set
  `PROJECT_AGENT` (e.g. `claude -c`) or `PROJECT_EDITOR` in `~/.bashrc.local` to change what the panes run.
- **wezterm**: Dracula, Meslo Nerd Font with JetBrains Mono fallback, F11 fullscreen, Shift+Enter inserts a
  newline in Claude Code.
- **nvim** (0.12, built-in `vim.pack`): fzf-lua, which-key, gitsigns, nvim-treesitter, mini.statusline,
  roslyn.nvim, Dracula. LSP for C# (Roslyn) and Go (gopls, with format and import organizing on save), built-in
  completion with auto-trigger. Markdown opens in a wrapped, spell-checked read mode; `<leader>m` toggles it.
  Space is the leader; `<leader>fk` searches every keymap by description, and which-key shows the rest.

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

Without tmux, or with no nvim in the window, the hook does nothing. After `link.sh` adds the hook, Claude Code
picks it up through its settings file watcher; nvim needs a restart to load `lua/claude.lua`.

## WSL

wezterm on Windows reads `%USERPROFILE%\.wezterm.lua`, a stub that `install/wezterm-windows.sh` writes to load
`home/wezterm.lua` over `\\wsl.localhost` and open the WSL distro by default. Its paste is `ctrl+shift+v`, so
`ctrl+v` reaches nvim's visual-block mode (Windows Terminal would need `ctrl+v` unbound). nvim reaches the
Windows clipboard through `win32yank.exe`, which `deps.sh` installs. `deps.sh` also disables `appendWindowsPath`
in `/etc/wsl.conf` (apply with `wsl --shutdown`); bashrc re-adds `System32` so `win32yank.exe`, `explorer.exe`
and `powershell.exe` stay reachable, and sets `BROWSER` so links open in Windows.

## Testing the bootstrap on a clean image

`Containerfile.debian` builds a bare Debian 12 with a sudo user. The comment at its top gives the build, run and
in-container commands; the whole sequence takes about three minutes and ends with every plugin and parser in place.
