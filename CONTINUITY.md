Goal (incl. success criteria):
- Commit and push the latest create-zkp2p-provider skill updates (CSRF replay guidance and Gotchas/Troubleshooting).

Constraints/Assumptions:
- Follow AGENTS instructions (ledger updates at start and on changes).
- Keep instructions concise and aligned with skill conventions.

Key decisions:
- Update both Codex and Claude SKILL.md files and regenerate dist artifacts.

State:
- Commit created; push rejected because remote has new commits.

Done:
- Committed changes to Codex/Claude SKILL.md and CONTINUITY.md.
- Added CSRF replay guidance and a Gotchas/Troubleshooting section in both SKILL.md files.
- Rebuilt dist artifacts via `./scripts/bundle-claude.sh` and `./scripts/package-codex.sh`.

Now:
- Resolve push rejection (rebase/merge) while preserving unrelated local changes.

Next:
- Push updated branch once remote changes are integrated.

Open questions (UNCONFIRMED if needed):
- How should we handle unrelated local changes in `README.md`, `scripts/install-claude.sh`, and `scripts/install-codex.sh` before rebasing/pushing?

Working set (files/ids/commands):
- CONTINUITY.md
- src/codex/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/SKILL.md
- dist/claude/create-zkp2p-provider.md
- dist/codex/create-zkp2p-provider.skill
- ./scripts/bundle-claude.sh
- ./scripts/package-codex.sh
