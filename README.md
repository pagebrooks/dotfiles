# dotfiles

bash, git, tmux, nvim and mise config, symlinked into `$HOME`.

```sh
git clone <url> ~/projects/dotfiles
~/projects/dotfiles/link.sh
```

`home/` maps to `~/.<name>`; `config/` maps to `~/.config/`. Secrets and machine-specific settings
go in `~/.bashrc.local`, which `bashrc` sources and git ignores.

`install/` has scripts for tools that are not in Debian's packages:

- `install/nvim.sh [stable|nightly|vX.Y.Z]` — Neovim release into `~/.local`
- `install/tree-sitter-cli.sh` — tree-sitter CLI; nvim-treesitter needs it to build parsers
