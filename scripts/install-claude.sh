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
