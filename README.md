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

The canonical, richer index lives in [skills/README.md](skills/README.md). This
table is kept in sync with it by the `check-readme-index` pre-commit hook.

### Rituals

| Skill | Description |
|---|---|
| [sitrep](skills/sitrep/) | Unified daily ops log on a SilverBullet workspace — `start`/`end` replace goodmorning + goodevening, no HTML |
| [cal](skills/cal/) | Google Calendar — fetch events, find free slots, check availability, schedule interview prep + scorecard blocks |
| [retro](skills/retro/) | Session retrospective that captures learnings and promotes them globally |
| [self-perf](skills/self-perf/) | Self-performance review from GitHub, Slack, Gmail, Calendar, Jira, and Granola data |
| [team-hud](skills/team-hud/) | ⚠️ WIP — heads-up display of team activity; blocked on Slack/Jira/Group roster access |
| [goodmorning](skills/goodmorning/) | ⚠️ DEPRECATED — use `/wk-sitrep start`. Retained as agent-spec reference only |
| [goodevening](skills/goodevening/) | ⚠️ DEPRECATED — use `/wk-sitrep end`. Retained as agent-spec reference only |

### Pull Request

| Skill | Description |
|---|---|
| [pr](skills/pr/) | Create draft PRs with stacking support and post-PR workflow |
| [pr-review](skills/pr-review/) | Thorough, critical code review with playground experiments and pending GitHub review comments |
| [pr-resolve](skills/pr-resolve/) | Interactively address PR review comments — implement fixes, draft responses, and resolve threads |
| [pr-update](skills/pr-update/) | Merge, patch-replay, or rebase a PR branch onto the latest base branch |
| [pr-break](skills/pr-break/) | Break an oversized PR into a stack of smaller, individually-shippable PRs |
| [pr-takeover](skills/pr-takeover/) | Take over another author's PR — overwrite or stack mode, full workflow, co-authorship |
| [pr-merge](skills/pr-merge/) | Merge a PR once CI is green, reviews approved, and all threads resolved; transition ticket, retro, cleanup |
| [adversarial-review](skills/adversarial-review/) | Pre-flight adversarial review before any push or PR transition |
| [self-review](skills/self-review/) | Post design-decision comments on your own PR for human reviewers |
| [jira](skills/jira/) | Sync Jira ticket state with the PR lifecycle — In Progress → In Review → Done |

### Communication

| Skill | Description |
|---|---|
| [slack](skills/slack/) | Compose and send Slack messages — announcements, review requests, status updates — in mrkdwn |

### Tools

| Skill | Description |
|---|---|
| [buildkite](skills/buildkite/) | Check build status, investigate failures, and view logs via `bk` CLI |
| [datadog](skills/datadog/) | Create and manage Datadog dashboards, monitors, SLOs, and notebooks via REST API |
| [colima](skills/colima/) | Ensure Colima is running before container ops; start with the right profile; clean restart on failure |
| [docker](skills/docker/) | Image tag verification, build debugging, ENTRYPOINT checks, and daemon troubleshooting |
| [devcontainer](skills/devcontainer/) | Create or debug a devcontainer for a mise-managed Rails app — Dockerfile, docker-compose, devcontainer.json |
| [mise](skills/mise/) | Polyglot runtime version manager — tool installation, `mise exec --` for missing tools, git hook activation |
| [gh](skills/gh/) | Scope all GitHub CLI operations to `$GITHUB_ORG` (model-invocable only) |
| [curl](skills/curl/) | Transport-safe curl idioms — `-sS`, exit-status capture, token hygiene on any parsed HTTP call |
| [silverbullet](skills/silverbullet/) | Create/edit/debug SilverBullet pages, widgets, dashboards — HTML blocks, checkboxes, space-style CSS |

### Workflows

| Skill | Description |
|---|---|
| [workflow](skills/workflow/) | Master orchestration for development tasks — incremental commits, testing, review, PR lifecycle, and retro (model-invocable only) |
| [plan](skills/plan/) | Grill → research → multi-persona validation → numbered, agent-parallelizable plan (Fable-class) |
| [arch-review](skills/arch-review/) | Critical evaluation of architecture docs, specs, plans, and estimates — SPOFs, unhappy paths, assumptions |
| [commit](skills/commit/) | Conventional commits with emoji, signing, and safe push behavior |
| [docs](skills/docs/) | Check for and update documentation affected by code changes |
| [testing-skeleton](skills/testing-skeleton/) | Frame test plans — behavioral over structural, happy+sad paths, mutation verification |
| [format](skills/format/) | Apply code-formatting preferences reconciled with repo lint configs |
| [workstyle](skills/workstyle/) | Code-quality orchestrator — runs the project-style probe, routes to the `workstyle-*` sub-skills |
| [workstyle-naming](skills/workstyle-naming/) | Naming gate — descriptive names, ALL_CAPS constants, boolean predicates, semantic accuracy |
| [workstyle-structure](skills/workstyle-structure/) | Layout & structure — guard clauses, nesting depth, magic values, duplication threshold |
| [workstyle-async](skills/workstyle-async/) | Async & concurrency — no temporal coupling, no unbounded chains, propagate errors |
| [workstyle-docs](skills/workstyle-docs/) | Code docs — public-API docs, WHY-not-WHAT comments, mandatory stale-comment removal |
| [workstyle-testing](skills/workstyle-testing/) | Testing intent — new-path coverage, behavior over implementation, mandatory sad paths |
| [workstyle-error-handling](skills/workstyle-error-handling/) | Error handling — no silent swallow, operational vs programmer errors |
| [workstyle-typescript](skills/workstyle-typescript/) | TS/JS idioms — const/no-var, no any, explicit return types, `??`/`?.`, `Promise.all` |
| [workstyle-python](skills/workstyle-python/) | Python idioms — type hints, f-strings, dataclass/TypedDict, pathlib, no mutable defaults |
| [workstyle-ruby](skills/workstyle-ruby/) | Ruby idioms — `?`/`!` naming, frozen_string_literal, guard returns, ASCII-only comments |
| [workstyle-go](skills/workstyle-go/) | Go idioms — errors as values, `%w` wrapping, table-driven tests, no library panic, defer |
| [workstyle-rust](skills/workstyle-rust/) | Rust idioms — no unwrap/expect in prod, `&str` params, derive Debug, clippy::all, `///` docs |
| [workstyle-shell](skills/workstyle-shell/) | Shell idioms — `set -euo pipefail`, quoted vars, `local`, capability-probe not error-parse |
| [refactor](skills/refactor/) | Validate that a refactor preserved behavior — diffs merge-base vs post-refactor, audits removed lines |
| [markdown](skills/markdown/) | Enforce 120-column width, heading hierarchy, Mermaid diagrams, and link validation |
| [mermaid](skills/mermaid/) | Author Mermaid diagrams that render on GitHub — `<br/>` not `\n`, quoted labels, supported types |
| [concise](skills/concise/) | Reduce response verbosity and token usage — brief/dense modes, on-demand context compression |
| [calver](skills/calver/) | Generate CalVer version strings in YYYY.MM.DD-HHMMSS format (auto-invoked on any version bump) |
| [learn](skills/learn/) | Post-completion learning capture — writes structured learning files for wk-sharpen distillation |
| [sharpen](skills/sharpen/) | Improve skills based on field reports by extracting principles without overfitting on examples |
| [skill](skills/skill/) | Scaffold a new wk-* skill from the canonical template, syncing both README indexes |
| [env](skills/env/) | Diagnose env-var availability; source `$HOME/.profile`, report missing vars |
| [worktree-cleanup](skills/worktree-cleanup/) | Clean up merged git worktrees and report unmerged ones |

## Environment Variables

| Variable | Required by | Description |
|----------|-------------|-------------|
| `WK_SKILLS_HOME` | All skills (learning capture) | Path to this skills repo (e.g., `~/gitc/skills`). Used by the post-completion learning hook on every skill and by [`wk-sharpen`](skills/sharpen/README.md) batch mode. |
| `GITHUB_ORG` | gh, goodmorning, goodevening | GitHub organization to scope `gh` CLI queries (PRs, issues, notifications). |
| `DATADOG_API_KEY` | datadog | Datadog API key for dashboard/monitor/SLO management. |
| `DATADOG_APP_KEY` | datadog | Datadog application key (read/write access). |
| `DATADOG_SITE` | datadog | Datadog site (optional, defaults to `datadoghq.com`). |
| `WK_SKILLS_TEAM_SLACK_HANDLE` | team-hud | Comma-separated Slack usergroup handles for the team(s) you track (e.g., `your-team`). Resolved to channels via a one-time cache at `$WK_SKILLS_HOME/config/team-hud.yaml`. |
| `WK_SKILLS_TEAM_JIRA` | team-hud | Comma-separated Jira project keys to scope team activity queries (e.g., `ENG,DATA`). |
| `WK_SKILLS_TEAM_GITHUB` | team-hud | GitHub org or `org/repo` filter to scope team PR/commit queries (e.g., `my-org`). |

Add these to your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
export WK_SKILLS_HOME="$HOME/gitc/skills"
export GITHUB_ORG="your-org"
export WK_SKILLS_TEAM_SLACK_HANDLE="my-team"   # Slack usergroup handle(s)
export WK_SKILLS_TEAM_JIRA="ENG,DATA"           # Jira project keys
export WK_SKILLS_TEAM_GITHUB="your-org"         # GitHub org
```

## Adding a New Skill

Invoke the [`skill`](skills/skill/) skill — it scaffolds the directory, writes
the full `SKILL.md` body + `README.md`, wires CalVer/learn hooks, syncs **both**
index tables, installs, and verifies:

```
/wk-skill <name> "Use when … (one-sentence description)"
```

[`wk-skill`](skills/skill/) keeps this table and [skills/README.md](skills/README.md) in sync on
every add; the `check-readme-index` pre-commit hook blocks any commit that
drifts. See [docs/how-to/creating-a-skill.md](docs/how-to/creating-a-skill.md)
for the manual fallback and the full guide.

## Documentation

- [Architecture](docs/architecture.md) — how skills work, the retro→sharpen self-improvement loop, and model routing
- [Architecture (HTML)](docs/architecture.html) — interactive team-shareable version with diagrams and tips
- [Creating a Skill](docs/how-to/creating-a-skill.md)
- [Installing Skills](docs/how-to/installing-skills.md)

## License

[MIT](LICENSE)
