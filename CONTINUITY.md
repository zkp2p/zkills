Goal (incl. success criteria):
- Push the updated create-zkp2p-provider guidance (single-escape responseMatches regex, aligned responseRedactions scope, payment-platform required fields) to `main`; success is committed and pushed changes.

Constraints/Assumptions:
- Follow AGENTS instructions (ledger updates at start and on changes).
- Keep `src/codex` and `src/claude` references in sync.
- Update relevant skill docs without reverting unrelated local changes.
- Use create-zkp2p-provider workflow guidance.

Key decisions:
- UNCONFIRMED: Whether to sync installed `~/.codex/skills/create-zkp2p-provider` after source updates.

State:
- In progress; ready to commit and push changes to main.

Done:
- Read ledger at start of this turn.
- Updated Codex/Claude SKILL workflow guidance for single-escape responseMatches regex, aligned responseRedactions scope, and payment-platform minimum field checklist.
- Updated Codex/Claude references: provider-fields, provider-template, provider-examples, extension-template-parsing, and network-capture with the new rules and aligned examples.

Now:
- Commit and push the updated skill docs/references to main.

Next:
- (Optional) Rebuild dist artifacts and/or sync `~/.codex/skills/create-zkp2p-provider` if requested.

Open questions (UNCONFIRMED if needed):
- Should the installed Codex skill copy in `~/.codex/skills/create-zkp2p-provider` be updated after changes?

Working set (files/ids/commands):
- CONTINUITY.md
- src/codex/create-zkp2p-provider/SKILL.md
- src/claude/create-zkp2p-provider/SKILL.md
- src/codex/create-zkp2p-provider/references/provider-fields.md
- src/claude/create-zkp2p-provider/references/provider-fields.md
- src/codex/create-zkp2p-provider/references/provider-examples.md
- src/claude/create-zkp2p-provider/references/provider-examples.md
- src/codex/create-zkp2p-provider/references/provider-template.md
- src/claude/create-zkp2p-provider/references/provider-template.md
- src/codex/create-zkp2p-provider/references/extension-template-parsing.md
- src/claude/create-zkp2p-provider/references/extension-template-parsing.md
- src/codex/create-zkp2p-provider/references/network-capture.md
- src/claude/create-zkp2p-provider/references/network-capture.md
