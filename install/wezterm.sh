#!/usr/bin/env bash
# wezterm from its own apt repo; Debian and Ubuntu do not package it. Not needed on WSL (Windows Terminal).
set -euo pipefail
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
sudo apt-get update -q
sudo apt-get install -y -q wezterm
echo "installed $(wezterm --version)"
