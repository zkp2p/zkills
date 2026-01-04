# ZKP2P Provider Template Skill

This repo hosts the ZKP2P provider template skill for guiding AI agents to create zkTLS/Reclaim provider templates. The skill works with both **Claude Code** and **Codex**.

## What This Skill Does

Guides users to turn payment-platform network requests into valid ZKP2P provider JSON templates by:
- Capturing network requests (HAR or intercepted)
- Mapping transaction fields (amount, date, recipient, status, currency)
- Producing provider JSON with proper selectors and redactions

## Repository Structure

```
skills/
├── src/                              # Skill source (shared)
│   └── zkp2p-provider-template/
│       ├── SKILL.md                  # Main skill definition
│       └── references/               # Supporting documentation
│           ├── network-capture.md
│           ├── provider-template.md
│           ├── provider-fields.md
│           ├── provider-examples.md
│           └── extension-template-parsing.md
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

### Claude Code

**Option 1: Install skill directory**
```bash
./scripts/install-claude.sh
```
This copies the skill to `~/.claude/skills/zkp2p-provider-template/`.

**Option 2: Bundle into single file**
```bash
./scripts/bundle-claude.sh
```
Creates `dist/claude/zkp2p-provider-template.md` - a self-contained skill file with all references embedded.

**Option 3: Manual**
Copy `src/zkp2p-provider-template/` to your Claude Code skills directory.

### Codex

**Option 1: Package and install**
```bash
./scripts/package-codex.sh
```
Creates `dist/codex/zkp2p-provider-template.skill`.

Then install using the Codex skill-installer:
```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install_skill.py \
  dist/codex/zkp2p-provider-template.skill
```

**Option 2: Use the Codex skill packaging system**
```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/package_skill.py \
  src/zkp2p-provider-template \
  dist/codex
```

## Usage

Once installed, invoke the skill when:
- Creating a new ZKP2P provider template
- Analyzing HAR files or network logs
- Translating API responses into template fields

The skill will guide you through:
1. Capturing network requests
2. Identifying transaction endpoints
3. Mapping fields to JSONPath/XPath selectors
4. Assembling the provider template JSON
5. Testing and iterating

## Development

### Editing the skill
Edit files in `src/zkp2p-provider-template/`. The SKILL.md contains the main workflow; references contain detailed documentation.

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
