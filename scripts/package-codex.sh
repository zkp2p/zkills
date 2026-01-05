#!/usr/bin/env bash
# Package Create ZKP2P Provider skill for Codex
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$REPO_ROOT/src/codex/create-zkp2p-provider"
DIST_DIR="$REPO_ROOT/dist/codex"

SKILL_NAME="create-zkp2p-provider"
OUTPUT="$DIST_DIR/${SKILL_NAME}.skill"

echo "Packaging Create ZKP2P Provider skill for Codex..."

# Create dist directory
mkdir -p "$DIST_DIR"

# Remove old artifact
rm -f "$OUTPUT"

# Create skill package using Python (more portable than zip command)
python3 << EOF
import zipfile
import os

src_dir = "$SRC_DIR"
output = "$OUTPUT"
skill_name = "$SKILL_NAME"

with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(src_dir):
        # Skip hidden files/dirs
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for file in files:
            if file.startswith('.'):
                continue
            filepath = os.path.join(root, file)
            arcname = os.path.relpath(filepath, os.path.dirname(src_dir))
            zf.write(filepath, arcname)

print(f"Created: {output}")
EOF

echo "Skill packaged: $OUTPUT"
echo ""
echo "To install in Codex, use the skill-installer or copy to \$CODEX_HOME/skills/"
