Goal (incl. success criteria):
- Move Chrome DevTools MCP installation guidance into the skill installation/setup section inside the create-zkp2p-provider skill (Codex + Claude), with reduced duplication elsewhere.

Constraints/Assumptions:
- Platform-specific skills under `src/claude` and `src/codex`.
- Keep Codex vs Claude MCP install commands distinct.
- Follow skill conventions and keep instructions concise.

Key decisions:
- Update both Codex and Claude skill variants for consistency.

State:
- Updated Codex/Claude SKILL.md installation section wording and references.

Done:
- Prior intake + setup prompt and payment-template alignment updates applied.
- Updated Codex/Claude SKILL.md to tie MCP install to skill installation/setup section and adjusted references.

Now:
- Await user confirmation or further tweaks.

Next:
- Apply any requested wording adjustments.

Open questions (UNCONFIRMED if needed):
- None.

Working set (files/ids/commands):
- CONTINUITY.md
- src/claude/create-zkp2p-provider/SKILL.md
- src/codex/create-zkp2p-provider/SKILL.md
