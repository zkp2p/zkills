# Create ZKP2P Provider Skill

This repo hosts the create-zkp2p-provider skill for guiding AI agents to create zkTLS/Reclaim provider templates. The skill works with both **Claude Code** and **Codex**.

## What This Skill Does

Guides users to turn target-platform network requests into valid ZKP2P provider JSON templates by:
- Capturing network requests via Chrome DevTools MCP
- Mapping user-specified proof fields (identity, account attributes, or transactions)
- Producing provider JSON with proper selectors and redactions
- Using short, stepwise prompts and an iterative capture loop to refine selectors

## Repository Structure

```
skills/
├── src/
│   ├── claude/
│   │   └── create-zkp2p-provider/
│   │       ├── SKILL.md              # Claude Code skill definition
│   │       └── references/           # Supporting documentation
│   └── codex/
│       └── create-zkp2p-provider/
│           ├── SKILL.md              # Codex skill definition
│           └── references/           # Supporting documentation
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

Chrome DevTools MCP is required for network capture. Install it in the client you use, then restart the client so the MCP server is loaded:

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

## Recommended workflow (UX)

1. Intake: confirm platform + UI location, and get permission for MCP capture.
2. Capture: grab one request/response first; confirm it includes the required fields.
3. Expand: capture list + detail or secondary endpoints only if fields are missing.
4. Map + confirm: summarize extracted fields and confirm with the user before finalizing.
5. Assemble + test: build the template, then validate in the developer portal.

Tips:
- Start small, then scale. Avoid capturing everything at once.
- Re-trigger actions in the UI to avoid stale CSRF/nonce tokens.

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
- **extension-template-parsing.md** - Extension parsing behavior

## License

MIT. See `LICENSE`.
