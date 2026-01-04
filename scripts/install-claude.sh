#!/usr/bin/env bash
# Install ZKP2P Provider Template skill for Claude Code
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src/zkp2p-provider-template"

# Claude Code skills directory
CLAUDE_SKILLS_DIR="${CLAUDE_HOME:-$HOME/.claude}/skills"

echo "Installing ZKP2P Provider Template skill for Claude Code..."

# Create skills directory if needed
mkdir -p "$CLAUDE_SKILLS_DIR"

# Copy skill directory
DEST_DIR="$CLAUDE_SKILLS_DIR/zkp2p-provider-template"
rm -rf "$DEST_DIR"
cp -r "$SRC_DIR" "$DEST_DIR"

echo "Skill installed to: $DEST_DIR"
echo ""
echo "To use: invoke /zkp2p-provider-template in Claude Code"
echo "Or reference the skill in your prompts."
