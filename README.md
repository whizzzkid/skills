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

### Rituals

| Skill | Description |
|---|---|
| [cal](skills/cal/) | Google Calendar — fetch events, find free slots, check availability |
| [goodmorning](skills/goodmorning/) | Morning prep — Slack, Gmail, Calendar, Granola, GitHub, and interactive HTML dashboard |
| [goodevening](skills/goodevening/) | End-of-day wrap-up — brag doc, meeting notes, action item tracking, communication audit, evening.md |
| [retro](skills/retro/) | Session retrospective that captures learnings and promotes them globally |
| [self-perf](skills/self-perf/) | Self-performance review from GitHub, Slack, Gmail, Calendar, Jira, and Granola data |

### Pull Request

| Skill | Description |
|---|---|
| [pr](skills/pr/) | Create draft PRs with stacking support and post-PR workflow |
| [pr-break](skills/pr-break/) | Break an oversized PR into a stack of smaller, individually-shippable PRs |
| [pr-resolve](skills/pr-resolve/) | Interactively address PR review comments — implement fixes, draft responses, and resolve threads |
| [pr-review](skills/pr-review/) | Thorough, critical code review with playground experiments and pending GitHub review comments |
| [pr-update](skills/pr-update/) | Rebase or patch-replay a PR branch onto the latest base branch |
| [self-review](skills/self-review/) | Post design-decision comments on your own PR for human reviewers |

### Tools

| Skill | Description |
|---|---|
| [buildkite](skills/buildkite/) | Check build status, investigate failures, and view logs via `bk` CLI |
| [datadog](skills/datadog/) | Create and manage Datadog dashboards, monitors, SLOs, and notebooks via REST API |
| [devcontainer](skills/devcontainer/) | Create or debug a devcontainer for a mise-managed Rails app — Dockerfile, docker-compose, devcontainer.json |
| [docker](skills/docker/) | Image tag verification, build debugging, ENTRYPOINT checks, and daemon troubleshooting |
| [gh](skills/gh/) | Scope all GitHub CLI operations to `$GITHUB_ORG` (model-invocable only) |
| [jira](skills/jira/) | Sync Jira ticket state with the PR lifecycle — In Progress → In Review → Done |
| [mise](skills/mise/) | Polyglot runtime version manager — tool installation, `mise exec --` for missing tools, git hook activation |

### Workflows

| Skill | Description |
|---|---|
| [calver](skills/calver/) | Generate CalVer version strings in YYYY.MM.DD-HHMMSS format (auto-invoked on any version bump) |
| [commit](skills/commit/) | Conventional commits with emoji, signing, and safe push behavior |
| [concise](skills/concise/) | Reduce response verbosity and token usage — brief/dense modes, on-demand context compression |
| [docs](skills/docs/) | Check for and update documentation affected by code changes |
| [format](skills/format/) | Apply code-formatting preferences reconciled with repo lint configs |
| [learn](skills/learn/) | Post-completion learning capture — writes structured learning files for wk-sharpen distillation |
| [markdown](skills/markdown/) | Enforce 120-column width, heading hierarchy, Mermaid diagrams, and link validation |
| [refactor](skills/refactor/) | Validate that a refactor preserved behavior — diffs merge-base vs post-refactor, audits removed lines |
| [sharpen](skills/sharpen/) | Improve skills based on field reports by extracting principles without overfitting on examples |
| [skill](skills/skill/) | Scaffold a new wk-* skill from the canonical template |
| [testing-skeleton](skills/testing-skeleton/) | Frame test plans — behavioral over structural, happy+sad paths, mutation verification |
| [workflow](skills/workflow/) | Master orchestration for development tasks — incremental commits, testing, review, PR lifecycle, and retro (model-invocable only) |
| [worktree-cleanup](skills/worktree-cleanup/) | Clean up merged git worktrees and report unmerged ones |

## Environment Variables

| Variable | Required by | Description |
|----------|-------------|-------------|
| `WK_SKILLS_HOME` | All skills (learning capture) | Path to this skills repo (e.g., `~/gitc/skills`). Used by the post-completion learning hook on every skill and by `wk-sharpen` batch mode. |
| `GITHUB_ORG` | gh, goodmorning, goodevening | GitHub organization to scope `gh` CLI queries (PRs, issues, notifications). |
| `DATADOG_API_KEY` | datadog | Datadog API key for dashboard/monitor/SLO management. |
| `DATADOG_APP_KEY` | datadog | Datadog application key (read/write access). |
| `DATADOG_SITE` | datadog | Datadog site (optional, defaults to `datadoghq.com`). |

Add these to your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
export WK_SKILLS_HOME="$HOME/gitc/skills"
export GITHUB_ORG="your-org"
```

## Adding a New Skill

1. Copy `skills/_template/` to `skills/your-skill-name/`
2. Edit `SKILL.md` with your skill's name, description, and instructions
3. See [docs/how-to/creating-a-skill.md](docs/how-to/creating-a-skill.md) for the full guide

## Documentation

- [Architecture](docs/architecture.md) — how skills work, the retro→sharpen self-improvement loop, and model routing
- [Architecture (HTML)](docs/architecture.html) — interactive team-shareable version with diagrams and tips
- [Creating a Skill](docs/how-to/creating-a-skill.md)
- [Installing Skills](docs/how-to/installing-skills.md)

## License

[MIT](LICENSE)
