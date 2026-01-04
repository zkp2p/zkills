Goal (incl. success criteria):
- Provide ZKP2P provider template skill for both Claude Code and Codex platforms.

Constraints/Assumptions:
- Single source of truth in src/ directory
- Platform-specific packaging via scripts/
- Artifacts go to dist/

Key decisions:
- Shared source for both platforms
- Claude Code: directory-based install or bundled single-file
- Codex: .skill package (zip format)

State:
- Repo refactored to support both Claude Code and Codex
- Scripts created for packaging/installation

Done:
- Refactored directory structure
- Created install-claude.sh, bundle-claude.sh, package-codex.sh
- Updated README with dual-platform instructions
- Verified both build scripts work

Now:
- Ready for use

Next:
- Users can install skill for their preferred platform

Open questions:
- None

Working set:
- src/zkp2p-provider-template/ (source)
- scripts/ (build scripts)
- dist/ (artifacts)
