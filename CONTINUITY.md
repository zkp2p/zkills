Goal (incl. success criteria):
- Move Chrome DevTools approval prompt into step 1 intake for create-zkp2p-provider skill instructions.

Constraints/Assumptions:
- Follow AGENTS instructions (ledger updates at start and on changes).
- Keep instructions concise and aligned with skill conventions.

Key decisions:
- Update both Codex and Claude SKILL.md files and regenerate dist artifacts.

State:
- User approved stashing unrelated changes; need to commit latest updates, rebase on origin/main, push, then restore stash.

Done:
- Updated Codex/Claude SKILL.md intake to ask for DevTools permission and confirm MCP install in step 1.
- Updated setup prompt to focus on login/navigation.
- Rebuilt dist artifacts via `./scripts/bundle-claude.sh` and `./scripts/package-codex.sh`.
- Added CSRF replay guidance and a Gotchas/Troubleshooting section in both SKILL.md files.
- Rebuilt dist artifacts via `./scripts/bundle-claude.sh` and `./scripts/package-codex.sh`.

Now:
- Commit latest changes, stash unrelated changes, rebase on origin/main, push, then restore stash.

Next:
- Confirm push status and summarize.

Open questions (UNCONFIRMED if needed):
- None.

Working set (files/ids/commands):
- CONTINUITY.md
- src/codex/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/SKILL.md
- dist/claude/create-zkp2p-provider.md
- dist/codex/create-zkp2p-provider.skill
- ./scripts/bundle-claude.sh
- ./scripts/package-codex.sh
