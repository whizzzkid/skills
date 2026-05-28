# Skills Architecture

A self-improving agent skill system. Skills teach agents *how* to do things.
Agents write retrospective notes when they finish. Those notes are distilled
back into the skills — so every future run benefits from every past mistake.

---

## How a Skill Works

Each skill is a single `SKILL.md` file with YAML frontmatter and markdown
instructions. The frontmatter declares when to activate, which tools to allow,
which model to use, and per-provider model overrides for cost control.

```
skills/
└── pr-resolve/
    └── SKILL.md          ← frontmatter + instructions
learnings/
└── skills/
    └── pr-resolve/
        ├── 2026-04-21_pending-review.md        ← raw learning
        └── 2026-04-21_pending-review.learned.md ← after distillation
.distilled-sources.log    ← tracks what has been processed
```

### Skill Frontmatter

```yaml
name: wk-pr-resolve
description: >-
  Address PR review comments interactively ...  ← agent trigger text
model: opus                                      ← default model tier
allowed-tools: [Bash, Read, Edit, Write, ...]   ← capability sandbox
metadata:
  version: '2026.04.22-070656'                  ← CalVer timestamp
  model:
    openai:  o3              ← high-tier override
    google:  gemini-2.5-pro
    meta:    llama-4-maverick
    openai:  gpt-4.1-mini   ← (low-tier skills use cheaper models)
    google:  gemini-2.5-flash
```

---

## Lifecycle: One Skill Execution

```mermaid
sequenceDiagram
    participant U as User
    participant A as Agent
    participant S as Skill (SKILL.md)
    participant L as learnings/skills/<name>/
    participant SH as wk-sharpen

    U->>A: Trigger (slash command or auto-detect)
    A->>S: Load SKILL.md
    S-->>A: Instructions + tool allowlist + model hint
    A->>A: Execute skill steps
    A->>L: Post-completion hook: write <date>_<slug>.md
    A-->>U: Result
    note over L: Accumulates until sharpen runs
    U->>SH: /wk-sharpen (manual or batch)
    SH->>L: Scan *.md (not *.learned.md)
    SH->>S: Distill principle → patch SKILL.md
    SH->>L: Rename → *.learned.md
    SH->>.distilled-sources.log: Append entry
```

---

## The Self-Improvement Loop

```mermaid
flowchart TD
    A[Agent runs skill] --> B[Post-completion hook fires]
    B --> C{Anything notable?}
    C -- no --> Z[Skip — no learning written]
    C -- yes --> D[Write learning to learnings/skills/name/date_slug.md]
    D --> E[Learning accumulates]

    E --> F[/wk-sharpen invoked/]
    F --> G[Scan learnings/*.md]
    G --> H[Read full SKILL.md]
    H --> I[Extract principle — remove specifics]
    I --> J[Patch SKILL.md]
    J --> K[Rename to *.learned.md]
    K --> L[Log to .distilled-sources.log]
    L --> M[Future agents use improved skill]
    M --> A
```

---

## Memory Sources: Two Input Channels for Sharpen

`wk-sharpen` pulls from two sources in batch mode:

```mermaid
flowchart LR
    subgraph Sources
        LS[learnings/skills/**/*.md]
        GM[~/.claude/memory/feedback_*.md]
    end

    subgraph Filter
        LOG[.distilled-sources.log]
    end

    subgraph Action
        SH[wk-sharpen]
        SK[SKILL.md patch]
    end

    LS --> SH
    GM --> SH
    LOG -->|skip if already processed| SH
    SH --> SK
    SK -->|rename *.learned.md| LS
    SK -->|append entry| LOG
```

**Learnings** — structured field reports written by agents after each run.
Contain skill name, type, severity, and a suggested fix.

**Global memory** — `~/.claude/memory/feedback_*.md` files from any session
in any project. Sharpen reads feedback-type memories and maps them to the
skill they describe.

---

## Agent-Agnostic Model Routing

Every skill declares a default model tier (`sonnet` or `opus`) and a
per-provider override table. The agent runtime picks the right model for
the platform in use — no code changes needed to switch providers.

```mermaid
flowchart LR
    SK[SKILL.md\nmodel: opus]
    SK --> CC[Claude Code → claude-opus-4-7]
    SK --> OA[OpenAI → o3]
    SK --> GG[Google → gemini-2.5-pro]
    SK --> ME[Meta → llama-4-maverick]
    SK --> CU[Cursor → composer-2]

    SK2[SKILL.md\nmodel: sonnet]
    SK2 --> CC2[Claude Code → claude-sonnet-4-6]
    SK2 --> OA2[OpenAI → gpt-4.1-mini]
    SK2 --> GG2[Google → gemini-2.5-flash]
    SK2 --> ME2[Meta → llama-4-scout]
    SK2 --> CU2[Cursor → composer-1.5]
```

Low-complexity skills (retro, calver, docs) use `sonnet`-tier models to
keep costs low. High-reasoning skills (pr-review, sharpen, workflow) use
`opus`-tier.

---

## Skill Inventory

| Skill | Tier | Role |
|-------|------|------|
| `wk-workflow` | opus | Master orchestration — invokes all others |
| `wk-pr-review` | opus | Thorough adversarial code review |
| `wk-sharpen` | opus | Distill learnings → improve skills |
| `wk-pr-resolve` | sonnet | Address reviewer feedback interactively |
| `wk-pr` | sonnet | Create and manage pull requests |
| `wk-commit` | sonnet | Conventional commits with signing |
| `wk-self-review` | sonnet | Post design-decision comments on own PR |
| `wk-retro` | sonnet | Session retrospective → global memory |
| `wk-goodmorning` | sonnet | Daily brief — Slack, Gmail, Calendar, GitHub |
| `wk-goodevening` | sonnet | End-of-day wrap-up and action tracking |
| `wk-buildkite` | sonnet | CI investigation and log reading |
| `wk-docs` | sonnet | Keep documentation in sync with code |
| `wk-mise` | sonnet | Runtime version management |
| `wk-docker` | sonnet | Image builds, daemon issues |
| `wk-datadog` | sonnet | Dashboards, monitors, SLOs |
| `wk-gh` | sonnet | GitHub CLI scoped to org |
| `wk-calver` | sonnet | Generate CalVer version strings |
| `wk-worktree-cleanup` | sonnet | Prune merged git worktrees |

---

## Installation

```bash
# Install all skills globally
npx skills add whizzzkid/skills

# Install a single skill
npx skills add whizzzkid/skills -s pr-resolve

# After editing skills locally, reinstall
npx skills add . -g -y -a=claude
```

Skills are installed into `~/.claude/skills/` and discovered automatically
by the agent at session start. The `description` field in frontmatter is
what the agent reads to decide whether to activate a skill.

---

## Environment Variables

| Variable | Used by | Purpose |
|----------|---------|---------|
| `WK_SKILLS_HOME` | All skills | Path to this repo — required for learning capture |
| `GITHUB_ORG` | gh, goodmorning, goodevening | Scope GitHub queries to org |
| `DATADOG_API_KEY` | datadog | API access |
| `DATADOG_APP_KEY` | datadog | Read/write access |
| `WK_SKILLS_TEAM_SLACK` | team-hud | Slack channel ID for the team roster |
| `WK_SKILLS_TEAM_JIRA` | team-hud | Comma-separated Jira project keys |
| `WK_SKILLS_TEAM_GITHUB` | team-hud | GitHub org or org/repo filter |
