# Agent Conventions

## Repository Structure

- Skills live in `skills/<skill-name>/SKILL.md`
- Each skill is a self-contained directory with a single `SKILL.md` file
- Optional `scripts/` and `references/` subdirectories for supporting files

## Naming Rules

- Skill names: always prefixed with `wk-` (e.g., `wk-my-cool-skill`)
- Skill directories: `kebab-case` (e.g., `my-cool-skill`) — no prefix in directory name
- Definition file: always `SKILL.md` (uppercase)
- Scripts: `kebab-case.sh` with executable permissions

## SKILL.md Format

```yaml
---
name: wk-skill-name
description: When and why to use this skill
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
---
```

Required fields: `name`, `description`

## Adding a Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with `name` and `description`
3. Write clear instructions in the markdown body
4. Update the skills table in `README.md`

## Guidelines

- Keep `SKILL.md` under 500 lines
- Write specific descriptions so agents activate the skill only when relevant
- Use `metadata.internal: true` for skills that should be hidden from discovery
- Skills are model-invocable by default — use `model-invocable: true` to
  explicitly enable, or `disable-model-invocation: true` to opt out.
  `disable-model-invocation: false` is a no-op and should not be used.

## Versioning

All skill versions use **CalVer** format: `YYYY.MM.DD-HHMMSS` (UTC).
Semver (`MAJOR.MINOR.PATCH`) is forbidden in this project.

Whenever a `metadata.version` field needs to be set or bumped, invoke
`wk-calver` to generate the correct UTC timestamp:

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

## Workflow

- Always commit and push after every change to this project
