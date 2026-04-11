# ZKP2P Skills

This repo hosts ZKP2P skills for **Claude Code** and **Codex**.

Current skills:
- `create-zkp2p-provider` for guiding AI agents to create zkTLS/Reclaim provider templates
- `query-zkp2p-indexer` for querying the ZKP2P Hasura indexer on Base and formatting protocol data

This repo is public. The skill is intentionally written against the current public provider interfaces and public-safe runtime behavior. Do not add private repo links, internal file paths, secrets, or raw sensitive captures to this repo.

## What This Skill Does

Guides users to turn target-platform network requests into valid ZKP2P provider JSON templates by:
- Capturing network requests via Chrome DevTools MCP
- Mapping user-specified proof fields (identity, account attributes, or transactions)
- Producing provider JSON with proper selectors and redactions
- Using short, stepwise prompts and an iterative capture loop to refine selectors
- Staying aligned with the provider file path and manifest contract used by current consumers
- Covering mobile-only provider fields that appear in real templates today

## Repository Structure

```
skills/
├── src/
│   ├── claude/
│   │   └── create-zkp2p-provider/
│   │       ├── SKILL.md              # Claude Code skill definition
│   │       └── references/           # Supporting documentation
│   └── codex/
│       ├── create-zkp2p-provider/
│       │   ├── SKILL.md              # Codex skill definition
│       │   └── references/           # Supporting documentation
│       └── query-zkp2p-indexer/
│           ├── SKILL.md              # Codex skill definition
│           ├── agents/openai.yaml    # Codex UI metadata
│           └── references/           # Query patterns and lookups
├── scripts/
│   ├── install-claude.sh            # Install for Claude Code
│   ├── bundle-claude.sh             # Bundle into single file
│   └── package-codex.sh             # Package for Codex
├── dist/
│   ├── claude/                       # Claude Code artifacts
│   └── codex/                        # Codex artifacts
└── README.md
```

## Installation

### Prerequisites (both clients)

Chrome DevTools MCP is the preferred capture/debugging path. Use it instead of Playwright-style browser automation unless the user explicitly asks for Playwright or MCP cannot reach the flow.

Before capture:
- Install Chrome DevTools MCP in the client you use, then restart the client so the MCP server is loaded.
- If the client does not expose the `chrome-devtools` skill or the `create-zkp2p-provider` skill, install or enable those skills before continuing.
- In the Chrome profile the user wants to reuse, open `chrome://inspect/#remote-debugging` and turn on remote debugging so MCP attaches to that existing browser session and reuses its cookies instead of spawning a fresh browser.

**Codex**
```bash
codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
```

**Claude Code**
```bash
claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
```

### Claude Code

**Option 1: Install skill directory**
```bash
./scripts/install-claude.sh
```
This copies the skill to `~/.claude/skills/create-zkp2p-provider/`.

**Option 2: Bundle into single file**
```bash
./scripts/bundle-claude.sh
```
Creates `dist/claude/create-zkp2p-provider.md` - a self-contained skill file with all references embedded.

**Option 3: Manual**
Copy `src/claude/create-zkp2p-provider/` to your Claude Code skills directory.

After installing the skill, restart Claude Code if you just added Chrome DevTools MCP.

### Codex

**Option 1: Local install (fastest)**
```bash
codex
$skill-installer https://github.com/zkp2p/zkills/tree/main/src/codex/create-zkp2p-provider
```

After installing the skill, restart Codex if you just added Chrome DevTools MCP.

### Codex: Query ZKP2P Indexer

```bash
codex
$skill-installer https://github.com/zkp2p/zkills/tree/main/src/codex/query-zkp2p-indexer
```

Use this skill when you want reusable GraphQL queries for deposits, intents, quote candidates, maker or taker stats, manager stats, or when raw bigint and hash fields need to be formatted for humans.

## Usage

Once installed, invoke the skill when:
- Creating a new ZKP2P provider template
- Analyzing network logs
- Translating API responses into template fields

The skill will guide you through:
1. Capturing network requests
2. Identifying transaction endpoints
3. Mapping fields to JSONPath/XPath selectors
4. Assembling the provider template JSON
5. Testing and iterating

## Public Interface Guardrails

- Treat the provider file path as part of the contract: consumers resolve configs at `{platform}/{actionType}.json`.
- Keep `metadata.platform`, the directory name, and any manifest entry in `providers.json` aligned.
- Use the current mobile field shape under `mobile.*` (`useExternalAction`, `external`, `internal`, `login`, `userAgent`, `additionalClientOptions`). Do not fall back to older shapes unless you have verified them.
- When a provider needs more than one proof, document the `additionalProofs` plan and remind the user that downstream client wrappers may also need their proof count updated.
- If you learned a constraint from a non-public repo, restate it as a public interface rule. Do not paste private code, links, or payloads into this repo.

## Recommended workflow (UX)

1. Intake: confirm platform + UI location, and get permission for MCP capture.
2. Capture: grab one request/response first; confirm it includes the required fields.
3. Expand: capture list + detail or secondary endpoints only if fields are missing.
4. Map + confirm: summarize extracted fields and confirm with the user before finalizing.
5. Assemble + test: build the template, then validate in the developer portal and, when relevant, against the hosted `/providers/{platform}/{actionType}.json` path.

Tips:
- Start small, then scale. Avoid capturing everything at once.
- Re-trigger actions in the UI to avoid stale CSRF/nonce tokens.
- Keep public docs focused on interface behavior, not private implementation details.

## Development

### Editing the skill
Edit files in `src/claude/create-zkp2p-provider/` and `src/codex/create-zkp2p-provider/`. Keep references in sync across both folders.

### Testing changes
After editing, rebuild for your platform:
```bash
# For Claude Code
./scripts/bundle-claude.sh

# For Codex
./scripts/package-codex.sh
```

## References

The skill includes these reference documents:
- **network-capture.md** - How to capture network requests
- **provider-template.md** - Template skeleton and patterns
- **provider-fields.md** - Field-by-field documentation
- **provider-examples.md** - Real examples from the providers repo
- **extension-template-parsing.md** - Public-safe runtime behavior and authoring implications

## License

MIT. See `LICENSE`.
