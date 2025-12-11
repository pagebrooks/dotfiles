set -euo pipefail

# Paths
OPT_DIR="$HOME/.local/opt/nvim-nightly"
STOW_DIR="$HOME/.local/stow"
PKG_NAME="nvim-nightly"
PKG_DIR="$STOW_DIR/$PKG_NAME"
# Repo root and config stow dir
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STOW_CONFIG_DIR="$REPO_ROOT/stow"

mkdir -p "$HOME/.local/bin" "$OPT_DIR" "$STOW_DIR"

# Fetch latest nightly tarball
curl -fL -o /tmp/nvim-linux-x86_64.tar.gz \
	https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

# Extract into ~/.local/opt/nvim-nightly
rm -rf "$OPT_DIR"/*
tar -xzf /tmp/nvim-linux-x86_64.tar.gz -C "$OPT_DIR" --strip-components=1

# Prepare Stow package layout: ~/.local/stow/nvim-nightly/bin/nvim
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/bin"

# Create a small launcher script so Stow symlinks a stable entry
cat > "$PKG_DIR/bin/nvim" << 'EOF'
#!/usr/bin/env bash
exec "$HOME/.local/opt/nvim-nightly/bin/nvim" "$@"
EOF
chmod +x "$PKG_DIR/bin/nvim"

# Remove previous stow links for this package, then stow fresh
stow -D -t "$HOME/.local" -d "$STOW_DIR" "$PKG_NAME" || true
stow -t "$HOME/.local" -d "$STOW_DIR" "$PKG_NAME"


echo "Installed nvim nightly via Stow. Run: nvim"
