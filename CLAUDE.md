# Claude Code Instructions

See [AGENTS.md](AGENTS.md) for project conventions and workflow rules.

## Versioning

All skill versions use **CalVer** format: `YYYY.MM.DD-HHMMSS` (UTC).
Semver (`MAJOR.MINOR.PATCH`) is forbidden in this project.

Whenever a `metadata.version` field needs to be set or bumped, invoke
`wk:calver` to generate the correct UTC timestamp:

```bash
date -u '+%Y.%m.%d-%H%M%S'
```

This applies to all skills, including `_template`.

## Post-Change Hook

After adding or updating any skill, always run:

```bash
npx skills add . -g -y -a=claude
```

This reinstalls all skills globally for the agent. Never skip this step.
