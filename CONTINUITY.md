Goal (incl. success criteria):
- Rebuild dist artifacts for updated MCP gating and push changes to main.

Constraints/Assumptions:
- Keep Codex vs Claude MCP install commands distinct.
- Follow skill conventions and keep instructions concise.

Key decisions:
- Update both Codex and Claude create-zkp2p-provider skill instructions to require user-driven MCP install first.
- Commit only MCP gating + dist rebuild + ledger updates; leave other modified files uncommitted.

State:
- Ready to stage selected files, commit, and push to main; other modified files remain unstaged.

Done:
- Updated `src/codex/create-zkp2p-provider/SKILL.md` MCP setup to require user install first and added a gating step.
- Updated `src/claude/create-zkp2p-provider/SKILL.md` MCP setup to require user install first and added a gating step.
- Ran `./scripts/bundle-claude.sh` and `./scripts/package-codex.sh` to rebuild dist artifacts.

Now:
- Stage selected files, commit, and push to main.

Next:
- Confirm push and report status.

Open questions (UNCONFIRMED if needed):
- None.

Working set (files/ids/commands):
- CONTINUITY.md
- src/codex/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/SKILL.md
