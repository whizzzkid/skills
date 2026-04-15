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
| [buildkite](skills/buildkite/) | Check build status, investigate failures, and view logs via `bk` CLI |
| [commit](skills/commit/) | Conventional commits with emoji, signing, and safe push behavior |
| [datadog](skills/datadog/) | Create and manage Datadog dashboards, monitors, SLOs, and notebooks via REST API |
| [docker](skills/docker/) | Image tag verification, build debugging, ENTRYPOINT checks, and daemon troubleshooting |
| [docs](skills/docs/) | Check for and update documentation affected by code changes |
| [gh](skills/gh/) | Scope all GitHub CLI operations to `$GITHUB_ORG` (model-invocable only) |
| [goodevening](skills/goodevening/) | End-of-day wrap-up — brag doc, meeting notes, action item tracking, communication audit, evening.md |
| [goodmorning](skills/goodmorning/) | Morning prep — Slack, Gmail, Calendar, Granola, GitHub, and interactive HTML dashboard |
| [pr](skills/pr/) | Create draft PRs with stacking support and post-PR workflow |
| [pr-resolve](skills/pr-resolve/) | Interactively address PR review comments — implement fixes, draft responses, and resolve threads |
| [pr-review](skills/pr-review/) | Thorough, critical code review with playground experiments and pending GitHub review comments |
| [retro](skills/retro/) | Session retrospective that captures learnings and promotes them globally |
| [self-review](skills/self-review/) | Post design-decision comments on your own PR for human reviewers |
| [sharpen](skills/sharpen/) | Improve skills based on field reports by extracting principles without overfitting on examples |
| [workflow](skills/workflow/) | Master orchestration for development tasks — incremental commits, testing, review, PR lifecycle, and retro (model-invocable only) |
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
