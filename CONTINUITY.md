Goal (incl. success criteria):
- Clean up the create-zkp2p-provider skill instructions to remove unnecessary early questions, proactively install Chrome DevTools MCP, and ensure the flow tells users to restart Codex when installing; success is updated skill docs reflecting this behavior.

Constraints/Assumptions:
- Follow AGENTS instructions (ledger updates at start and on changes).
- Update the relevant skill file(s) without reverting unrelated local changes.
- Use create-zkp2p-provider and skill-installer workflows for guidance.

Key decisions:
- Updated both the repo copy and the installed `~/.codex/skills` copy for immediate behavior change.

State:
- Prior conflict resolution work is complete (see Done).

Done:
- Read ledger at start of this turn.
- Updated `src/codex/create-zkp2p-provider/SKILL.md` to reduce upfront questions, enforce MCP install+restart guidance, and add recipient ID stability context with web research.
- Synced `/home/ubuntu/.codex/skills/create-zkp2p-provider/SKILL.md` to match the updated skill.
- Updated `src/claude/create-zkp2p-provider/SKILL.md` for parity with the Codex version.
- Updated `README.md` with Codex/Claude installation prerequisites and restart guidance, and fixed Codex option numbering.

Now:
- Prepare and push changes to `main`.

Next:
- Confirm push result.

Open questions (UNCONFIRMED if needed):
- None.

Working set (files/ids/commands):
- CONTINUITY.md
- src/codex/create-zkp2p-provider/SKILL.md
- /home/ubuntu/.codex/skills/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/SKILL.md
- README.md
