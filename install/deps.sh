#!/usr/bin/env bash
# Packages and small tools the bash/tmux/nvim config depends on. Debian 12 and Ubuntu, including WSL.
# Safe to re-run. nvim and tree-sitter have their own scripts: install/nvim.sh, install/tree-sitter-cli.sh.
set -euo pipefail

bin="$HOME/.local/bin"
mkdir -p "$bin"
on_wsl=${WSL_DISTRO_NAME:-}

pkgs=(git curl ca-certificates build-essential unzip ripgrep fd-find bat tmux)
if [ -n "$on_wsl" ]; then
    pkgs+=(wslu) # wslview: open URLs in the Windows browser
fi
sudo apt-get update -q
sudo apt-get install -y -q "${pkgs[@]}"

# Debian and Ubuntu rename these to avoid clashes; nvim, fzf-lua and bashrc expect the real names
ln -sfn "$(command -v fdfind)" "$bin/fd"
ln -sfn "$(command -v batcat)" "$bin/bat"

# mise manages go/node/dotnet. Debian has it from the mise apt repo; elsewhere use the installer (-> ~/.local/bin/mise).
if ! command -v mise >/dev/null && [ ! -x "$bin/mise" ]; then
    curl -fsSL https://mise.run | sh
fi

# fzf from git: apt's build is years behind. The installer writes ~/.fzf.bash (bashrc sources it)
# and, with these flags, asks nothing and leaves the rc files alone.
if [ -d "$HOME/.fzf" ]; then
    git -C "$HOME/.fzf" pull -q --ff-only
else
    git clone -q --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi
"$HOME/.fzf/install" --key-bindings --completion --no-update-rc >/dev/null

if [ -n "$on_wsl" ]; then
    # Windows clipboard for nvim (init.lua sets vim.g.clipboard = "win32yank" on WSL)
    if [ ! -x "$bin/win32yank.exe" ]; then
        tmp=$(mktemp -d)
        curl -fsSL -o "$tmp/win32yank.zip" https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
        unzip -q -o "$tmp/win32yank.zip" win32yank.exe -d "$tmp"
        install -m 755 "$tmp/win32yank.exe" "$bin/win32yank.exe"
        rm -rf "$tmp"
    fi
    # Stop WSL appending the whole Windows PATH (slow completion, .exe files shadowing Linux tools).
    # bashrc adds System32 back for the few .exe tools in use. Applies after `wsl --shutdown`.
    if ! grep -qs appendWindowsPath /etc/wsl.conf; then
        printf '\n[interop]\nappendWindowsPath = false\n' | sudo tee -a /etc/wsl.conf >/dev/null
        echo "added [interop] appendWindowsPath = false to /etc/wsl.conf; run 'wsl --shutdown' from Windows to apply"
    fi
fi

echo "deps installed: $(fd --version), $(rg --version | head -1), fzf $("$HOME/.fzf/bin/fzf" --version | cut -d' ' -f1), $(mise --version 2>/dev/null | head -1)"
