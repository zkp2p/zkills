Goal (incl. success criteria):
- Update README to reflect improved UX/prompts and push changes to `main`; success is README updated and changes pushed.

Constraints/Assumptions:
- Follow AGENTS instructions (ledger updates at start and on changes).
- Keep `src/codex` and `src/claude` references in sync unless divergence is required.
- Do not revert unrelated local changes.
- Use good skills/reference prompts from `../dev-browser` as source of improvements.

Key decisions:
- UNCONFIRMED: Which specific files/sections in `../dev-browser` should be mirrored or adapted.

State:
- Changes committed and pushed to main.

Done:
- Read ledger at start of this turn.
- Reviewed `../dev-browser` skill and reference prompts for reusable UX patterns.
- Updated Codex/Claude `SKILL.md` with clearer approach selection, workflow loop, prompts, and recovery guidance.
- Added "Start small, then scale" guidance to network capture references.
- Verified Codex/Claude versions align (only expected client-specific install instructions differ).
- Updated `README.md` with UX workflow and tips.
- Committed and pushed changes to `main`.

Now:
- Await further requests.

Next:
- (Optional) Rebuild dist artifacts or package skills if requested.

Open questions (UNCONFIRMED if needed):
- UNCONFIRMED: Should dist artifacts be rebuilt after README update?

Working set (files/ids/commands):
- CONTINUITY.md
- README.md
