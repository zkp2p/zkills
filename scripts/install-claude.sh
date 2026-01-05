#!/usr/bin/env bash
# Install Create ZKP2P Provider skill for Claude Code
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src/claude/create-zkp2p-provider"

# Claude Code skills directory
CLAUDE_SKILLS_DIR="${CLAUDE_HOME:-$HOME/.claude}/skills"

echo "Installing Create ZKP2P Provider skill for Claude Code..."

# Create skills directory if needed
mkdir -p "$CLAUDE_SKILLS_DIR"

# Copy skill directory
DEST_DIR="$CLAUDE_SKILLS_DIR/create-zkp2p-provider"
rm -rf "$DEST_DIR"
cp -r "$SRC_DIR" "$DEST_DIR"

echo "Skill installed to: $DEST_DIR"
echo ""
echo "To use: invoke /create-zkp2p-provider in Claude Code"
echo "Or reference the skill in your prompts."
echo ""
echo "Installing Chrome DevTools MCP for Claude Code..."
if ! command -v claude >/dev/null 2>&1; then
  echo "Error: 'claude' command not found. Install Claude Code CLI to add MCP." >&2
  exit 1
fi
if claude mcp add chrome-devtools npx chrome-devtools-mcp@latest; then
  echo "Chrome DevTools MCP installed."
else
  echo "Warning: Chrome DevTools MCP install failed or already installed; verify with 'claude mcp list'." >&2
fi
