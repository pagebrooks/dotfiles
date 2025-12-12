
#!/usr/bin/env bash
set -euo pipefail

if command -v claude >/dev/null 2>&1; then
	echo "Claude Code is already installed (command 'claude' found). Skipping."
else
	echo "Installing Claude Code..."
	curl -fsSL https://claude.ai/install.sh | bash
fi