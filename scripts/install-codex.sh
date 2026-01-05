#!/usr/bin/env bash
# Install Create ZKP2P Provider skill for Codex
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src/codex/create-zkp2p-provider"

# Codex skills directory
CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

echo "Installing Create ZKP2P Provider skill for Codex..."

# Create skills directory if needed
mkdir -p "$CODEX_SKILLS_DIR"

# Copy skill directory
DEST_DIR="$CODEX_SKILLS_DIR/create-zkp2p-provider"
rm -rf "$DEST_DIR"
cp -r "$SRC_DIR" "$DEST_DIR"

echo "Skill installed to: $DEST_DIR"
echo ""
echo "Installing Chrome DevTools MCP for Codex..."
if ! command -v codex >/dev/null 2>&1; then
  echo "Error: 'codex' command not found. Install Codex CLI to add MCP." >&2
  exit 1
fi
if codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest; then
  echo "Chrome DevTools MCP installed."
else
  echo "Warning: Chrome DevTools MCP install failed or already installed; verify with 'codex mcp list'." >&2
fi
echo ""
echo "Restart Codex to pick up new skills."
