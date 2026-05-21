# Agent Conventions

## Repository Structure

- Skills live in `skills/<skill-name>/SKILL.md` — each skill has a `group:` frontmatter field indicating its logical group (`rituals`, `pull-request`, `tools`, `workflows`)
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

1. Create `skills/<skill-name>/SKILL.md` and set `group:` in frontmatter
2. Add YAML frontmatter with `name` and `description`
3. Write clear instructions in the markdown body
4. Update the skills table in `README.md`
5. Write `README.md` following the template in `skills/README.md`

## README Maintenance

Every skill directory MUST contain a `README.md` alongside its `SKILL.md`. The README follows
the per-skill format established in `skills/README.md` (name heading, purpose, invocation trigger,
key phases or rules, and integration points).

**Co-change rule:** When `SKILL.md` changes — description, invocation behavior, phases, hard rules,
or integration points — the corresponding `README.md` MUST be updated in the **same commit**.
No exceptions; a SKILL.md update without a README.md update is an incomplete commit.

**Rename/remove rule:** When a skill is renamed or removed, its `README.md` must be
renamed/deleted in the same commit as the `SKILL.md` change.

**Root index rule:** `skills/README.md` (the top-level skills index) MUST be updated whenever:
- A skill is added or removed
- A skill's `group:` field changes
- A skill's one-line `description:` changes materially

**Drift check (pre-sharpen gate):** Before any `wk-sharpen` commit lands, verify the modified
`SKILL.md`'s `name:` frontmatter value matches the `# wk-*` heading in its `README.md`. If they
diverge, fail and fix before committing:

```bash
skill_name=$(grep '^name:' skills/<skill-name>/SKILL.md | awk '{print $2}')
readme_heading=$(grep '^# wk-' skills/<skill-name>/README.md | head -1 | sed 's/^# //')
[ "$skill_name" = "$readme_heading" ] || echo "DRIFT: $skill_name != $readme_heading"
```

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

## Environment-Specific Identifiers

**HARD RULE: Never commit employer or organization names as literals.** This
repository is public and employer-agnostic. All employer/org references must be
dynamic, resolved from environment variables at runtime:

- **`$EMPLOYER`** — the user's current employer name (e.g. set in `~/.zshrc` or `~/.claude/profile.sh`)
- **`$GITHUB_ORG`** — the user's GitHub organization slug (already enforced by `wk-gh`)

Rules:
- Never write an employer name, org name, or company slug as a literal string in any `SKILL.md`, `README.md`, `AGENTS.md`, script, or reference file.
- Never commit learnings, notes, or reference files that contain a literal employer/org name. Scrub before committing: replace literals with `$EMPLOYER` or `$GITHUB_ORG`.
- MCP tool name patterns that embed an org/employer slug must use `${EMPLOYER}` interpolation (e.g. `mcp__claude_ai_Gcal_${EMPLOYER}__*`).
- If you encounter a literal employer or org name anywhere in the tree during a sharpen/edit pass, replace it in the same commit.

Pre-commit check:

```bash
# Fail if any literal employer token lands in a commit
git diff --cached | grep -iE '\b($EMPLOYER|your-company|example-corp)\b' && echo "BLOCKED: literal employer name in diff"
```

Replace the grep pattern with the actual employer token(s) in your environment's pre-commit hook.

## Workflow

- Always commit and push after every change to this project
