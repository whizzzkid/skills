# Installing Skills

## Prerequisites

- Node.js installed
- An AI coding agent that supports the [Agent Skills spec](https://github.com/vercel-labs/skills)

## Install All Skills

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
npx skills add whizzzkid/skills -a claude
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
npx skills check
```

Lists all installed skills and validates their configuration.

## Update Skills

```bash
npx skills update whizzzkid/skills
```

Pulls the latest version of all installed skills from this repository.

## Uninstall

Remove the skill directory from your agent's skills folder (e.g., `~/.claude/skills/` or `.claude/skills/` in your project).
