#!/usr/bin/env bash
# WSL only: point wezterm on Windows at this repo's home/wezterm.lua, so the Windows work machine and the
# Debian laptop share one config. Writes %USERPROFILE%\.wezterm.lua as a stub that loads the repo file over
# \\wsl.localhost and opens the current distro by default. Safe to re-run. Run it from the main checkout,
# not a worktree: the stub points at whichever copy of the repo ran it.
set -euo pipefail

[ -n "${WSL_DISTRO_NAME:-}" ] || { echo "run this from WSL; on Debian use install/wezterm.sh"; exit 1; }

dotfiles=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
src=$(wslpath -w "$dotfiles/home/wezterm.lua") # \\wsl.localhost\<distro>\home\...
stub="$(wslpath "$(wslvar USERPROFILE)")/.wezterm.lua"

if [ ! -x "/mnt/c/Program Files/WezTerm/wezterm-gui.exe" ]; then
    echo "note: wezterm is not installed on Windows; from PowerShell: winget install wez.wezterm"
fi

if [ -e "$stub" ] && ! grep -qs 'install/wezterm-windows.sh' "$stub"; then
    mv "$stub" "$stub.bak-$(date +%Y%m%d-%H%M%S)"
    echo "backup  $stub"
fi

cat > "$stub" <<EOF
-- Written by dotfiles install/wezterm-windows.sh. The real config is in the WSL repo; edit it there.
local wezterm = require 'wezterm'
local path = [[$src]]
wezterm.add_to_config_reload_watch_list(path)
local config = dofile(path)
config.default_domain = 'WSL:$WSL_DISTRO_NAME'
return config
EOF
echo "wrote   $stub -> $src"
