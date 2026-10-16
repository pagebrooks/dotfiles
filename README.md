# dotfiles

bash, git, tmux, wezterm, nvim and mise config, symlinked into `$HOME`. Works on Debian 12 (personal
machine) and Ubuntu under WSL with Windows Terminal (work machine) from the same files: bashrc and
init.lua detect WSL at runtime; per-machine values live in gitignored `.local` files.

```sh
git clone <url> ~/projects/dotfiles
cd ~/projects/dotfiles
install/deps.sh            # apt packages, fd/bat symlinks, mise, fzf; on WSL also win32yank + wsl.conf
install/nvim.sh            # Neovim release into ~/.local (stable | nightly | vX.Y.Z)
install/tree-sitter-cli.sh # tree-sitter CLI; nvim-treesitter needs it to build parsers
./link.sh                  # symlinks; backs up anything real that is in the way
install/wezterm.sh         # optional: wezterm from its apt repo (not on WSL)
install/claude-code.sh     # optional: Claude Code
```

`home/` maps to `~/.<name>`; `config/` maps to `~/.config/`.

Per-machine files, never committed:

- `~/.bashrc.local` — secrets and local env; sourced at the end of bashrc
- `~/.gitconfig.local` — `[user] email`, `signingkey`, `[credential]` helpers; included at the end of gitconfig

To try the bootstrap on a clean image, see the comment at the top of `Containerfile.debian`.

WSL notes: in Windows Terminal unbind `ctrl+v` (its default paste binding steals nvim's visual-block mode).
`install/deps.sh` disables `appendWindowsPath` in `/etc/wsl.conf`; bashrc re-adds `System32` so
`win32yank.exe`, `explorer.exe` and `powershell.exe` stay reachable.
