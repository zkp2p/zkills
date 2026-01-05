Goal (incl. success criteria):
- Update create-zkp2p-provider skill to add an explicit first-step intake (payment vs other), require Chrome DevTools MCP, prompt the user to log in when platform is unknown, and align payment flows to reference templates.

Constraints/Assumptions:
- Platform-specific skills under `src/claude` and `src/codex`.
- Keep Codex vs Claude MCP install commands distinct.
- Follow skill conventions and keep instructions concise.

Key decisions:
- Update both Codex and Claude skill variants for consistency.

State:
- Intake prompt, MCP setup prompt, and payment-template alignment added to both Codex/Claude skill workflows.

Done:
- Updated `src/codex/create-zkp2p-provider/SKILL.md` and `src/claude/create-zkp2p-provider/SKILL.md` with intake + setup prompts, login guidance, and payment-template alignment.

Now:
- Await user confirmation or further adjustments.

Next:
- Apply any follow-up edits if requested.

Open questions (UNCONFIRMED if needed):
- None.

Working set (files/ids/commands):
- src/claude/create-zkp2p-provider/SKILL.md
- src/codex/create-zkp2p-provider/SKILL.md
