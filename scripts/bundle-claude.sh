#!/usr/bin/env bash
# Bundle Create ZKP2P Provider skill into a single markdown file for Claude Code
# This creates a self-contained file with all references embedded
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src/claude/create-zkp2p-provider"
DIST_DIR="$REPO_ROOT/dist/claude"

OUTPUT="$DIST_DIR/create-zkp2p-provider.md"

echo "Bundling Create ZKP2P Provider skill for Claude Code..."

mkdir -p "$DIST_DIR"

# Start with the Claude-specific SKILL (skip frontmatter for bundled version, but keep name/desc)
cat > "$OUTPUT" << 'HEADER'
# Create ZKP2P Provider Skill

> Create or update ZKP2P provider templates (zkTLS/Reclaim) by capturing target-platform network requests, mapping user-specified proof fields (identity, account attributes, or transactions), and producing the JSON provider template.

HEADER

# Extract content after frontmatter from SKILL.md
sed -n '/^---$/,/^---$/d; /^# Create ZKP2P/,$p' "$SRC_DIR/SKILL.md" >> "$OUTPUT"

# Append each reference file
for ref in network-capture provider-template provider-fields provider-examples extension-template-parsing; do
    echo "" >> "$OUTPUT"
    echo "---" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    cat "$SRC_DIR/references/${ref}.md" >> "$OUTPUT"
done

echo "Bundled skill: $OUTPUT"
echo ""
echo "This single-file skill can be used directly with Claude Code."
