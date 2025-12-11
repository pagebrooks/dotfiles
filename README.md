## Managing Neovim with Stow

- Repo package: `stow/nvim/.config/nvim/` contains your Neovim config.
- Install per-user links:
	- Ensure GNU Stow is installed: `sudo apt-get install -y stow`
	- Run: `stow -t "$HOME" -d stow nvim`
- Unstow to remove symlinks: `stow -D -t "$HOME" -d stow nvim`

This will create symlinks under `~/.config/nvim` pointing to files in the repo.
## Installation