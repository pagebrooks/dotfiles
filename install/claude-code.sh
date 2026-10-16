#!/usr/bin/env bash
# Claude Code via the official installer; it keeps itself up to date afterwards.
set -euo pipefail
if command -v claude >/dev/null; then
    echo "claude already installed: $(claude --version)"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi
