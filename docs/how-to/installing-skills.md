# Installing Skills

## Prerequisites

- Node.js installed
- An AI coding agent that supports the [Agent Skills spec](https://github.com/vercel-labs/skills)

## Full Install (skills + hooks) — recommended

```bash
git clone git@github.com:whizzzkid/skills.git "$HOME/gitc/skills"
cd "$HOME/gitc/skills"
scripts/install-skills.sh
```

This installs every skill globally **and** registers the skill-shipped hooks
(scope-guard, env-var check, concise reminder, profile sourcing) into
`$HOME/.claude/settings.json`. It is idempotent — re-run it after `git pull` to
pick up new skills and any newly-declared hooks without duplicating entries (a
`.bak` of the settings file is written). Hooks are declared in
`scripts/hooks-manifest.json`; add an entry there when a new skill ships a hook
that must be wired into `settings.json` on every machine.

The `npx skills add` commands below install skills **only** — they do not wire
up hooks, so scope-guard and the env/concise hooks stay inactive. Use the full
install above unless you specifically want skills without their hooks.

## Install All Skills (skills only, no hooks)

```bash
npx skills add whizzzkid/skills
```

This installs every public skill from this repository into your agent's skills directory.

## Install a Specific Skill

```bash
npx skills add whizzzkid/skills -s skill-name
```

Replace `skill-name` with the name from the skill's frontmatter.

## Target a Specific Agent

```bash
npx skills add whizzzkid/skills --agent claude-code
npx skills add whizzzkid/skills -a cursor
npx skills add whizzzkid/skills -a copilot
```

## Install Globally

```bash
npx skills add whizzzkid/skills -g
```

Global skills are available across all your projects.

## Verify Installation

```bash
npx skills list -g
```

Lists all globally installed skills. For local source validation, use
`npx skills add . --list`.

## Update Skills

```bash
npx skills update whizzzkid/skills
```

Pulls the latest version of all installed skills from this repository.

## Uninstall

Remove the skill directory from your agent's skills folder (e.g., `~/.claude/skills/` or `.claude/skills/` in your project).
