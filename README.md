# Agent Scripts

This repo hosts Codex skills and packaging artifacts used by ZKP2P to guide provider template creation.

## Contents
- Skill source: `skills/public/zkp2p-provider-template/`
- Packaged artifact: `dist/zkp2p-provider-template.skill`

## Usage
- Edit the skill in `skills/public/zkp2p-provider-template/`.
- Repackage after edits:

```bash
python3 ~/.codex/skills/.system/skill-creator/scripts/package_skill.py \
  skills/public/zkp2p-provider-template \
  dist
```

## Notes
- The skill references public-safe documentation, including extension parsing behavior.
- The packaged `.skill` file is intended for distribution to Codex environments.

## License
MIT. See `LICENSE`.
