#!/usr/bin/env bash
# roslyn-language-server as a global dotnet tool (-> ~/.dotnet/tools, which bashrc puts on PATH);
# roslyn.nvim starts it for C# buffers. Installs, or updates if already installed.
# Usage: install/roslyn.sh [nuget|azure]   nuget = nuget.org (default)
#                                          azure = Microsoft's feed, newer builds, what VS Code uses
set -euo pipefail

command -v dotnet >/dev/null || { echo "dotnet not found; install a .NET SDK first"; exit 1; }

src=()
case ${1:-nuget} in
    nuget) ;;
    azure) src=(--source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json) ;;
    *) echo "usage: $0 [nuget|azure]"; exit 1 ;;
esac

action=install
if dotnet tool list -g | grep -q '^roslyn-language-server '; then
    action=update
fi
dotnet tool "$action" -g roslyn-language-server --prerelease "${src[@]}"

echo "installed $(dotnet tool list -g | awk '$1 == "roslyn-language-server" { print $1, $2 }') to ~/.dotnet/tools"
