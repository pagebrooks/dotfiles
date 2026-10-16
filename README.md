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
  to `~/.claude/statusline.sh` (linked from `config/claude/statusline.sh`)

To try the bootstrap on a clean image, see the comment at the top of `Containerfile.debian`.

WSL notes: wezterm on Windows reads `%USERPROFILE%\.wezterm.lua`, a stub that `install/wezterm-windows.sh`
writes to load `home/wezterm.lua` over `\\wsl.localhost` and open the WSL distro by default. Its paste is
`ctrl+shift+v`, so `ctrl+v` reaches nvim's visual-block mode (Windows Terminal needs `ctrl+v` unbound).
`install/deps.sh` disables `appendWindowsPath` in `/etc/wsl.conf`; bashrc re-adds `System32` so
`win32yank.exe`, `explorer.exe` and `powershell.exe` stay reachable.
