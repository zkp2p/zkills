Goal (incl. success criteria):
- Fix Codex local install/testing guidance now that install_skill.py is not present.

Constraints/Assumptions:
- Platform-specific skills under `src/claude` and `src/codex`.
- Platform-specific packaging via scripts/.
- Artifacts go to dist/.
- Skill should follow each agent's conventions.

Key decisions:
- Shared source for both platforms
- Claude Code: directory-based install or bundled single-file
- Codex: .skill package (zip format)

State:
- Repo refactored to support both Claude Code and Codex
- Scripts created for packaging/installation
- Skill moved into platform-specific folders and renamed to create-zkp2p-provider.

Done:
- Split skill into `src/claude/create-zkp2p-provider` and `src/codex/create-zkp2p-provider`
- Renamed skill to create-zkp2p-provider in both SKILL.md files
- Updated scripts and README for new paths and artifact names
- Updated Codex/Claude SKILL.md to require MCP install first and use use-case-driven intake
- Generalized network capture and provider-template references for identity/account flows

Now:
- Provide correct local Codex install steps and update docs if needed.

Next:
- Apply any follow-up adjustments if requested.

Open questions (UNCONFIRMED if needed):
- None.

Working set:
- src/claude/create-zkp2p-provider/SKILL.md
- src/codex/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/references/
- src/codex/create-zkp2p-provider/references/
- scripts/bundle-claude.sh
- scripts/install-claude.sh
- scripts/package-codex.sh
- README.md
