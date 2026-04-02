# whizzzkid/skills

Personal agent skills for AI coding assistants. Compatible with the [Agent Skills](https://github.com/vercel-labs/skills) specification — works across 40+ agents.

## Installation

```bash
npx skills add whizzzkid/skills
```

Install a specific skill:

```bash
npx skills add whizzzkid/skills -s skill-name
```

## Available Skills

| Skill | Description |
|-------|-------------|
| [commit](skills/commit/) | Conventional commits with emoji, signing, and safe push behavior |
| [docs](skills/docs/) | Check for and update documentation affected by code changes |
| [pr](skills/pr/) | Create draft PRs with stacking support and post-PR workflow |
| [pr-review](skills/pr-review/) | Thorough, critical code review with playground experiments and pending GitHub review comments |
| [retro](skills/retro/) | Session retrospective that captures learnings and promotes them to project files |
| [self-review](skills/self-review/) | Post design-decision comments on your own PR for human reviewers |
| [worktree-cleanup](skills/worktree-cleanup/) | Clean up merged git worktrees and report unmerged ones |

## Adding a New Skill

1. Copy `skills/_template/` to `skills/your-skill-name/`
2. Edit `SKILL.md` with your skill's name, description, and instructions
3. See [docs/how-to/creating-a-skill.md](docs/how-to/creating-a-skill.md) for the full guide

## Documentation

- [Creating a Skill](docs/how-to/creating-a-skill.md)
- [Installing Skills](docs/how-to/installing-skills.md)

## License

[MIT](LICENSE)
