---
name: wk:buildkite
description: >-
  Use when working with Buildkite CI — checking build status, investigating
  failures, viewing job logs, or monitoring builds after push. Activates on
  Buildkite URLs, CI failure investigation, build monitoring, or `bk` CLI
  operations. Use this instead of GitHub tools for CI status.
allowed-tools:
  # Read-only bk commands
  - "Bash(bk build view:*)"
  - "Bash(bk build list:*)"
  - "Bash(bk build watch:*)"
  - "Bash(bk build download:*)"
  - "Bash(bk job list:*)"
  - "Bash(bk job log:*)"
  - "Bash(bk artifacts list:*)"
  - "Bash(bk artifacts download:*)"
  - "Bash(bk agent list:*)"
  - "Bash(bk agent view:*)"
  - "Bash(bk pipeline list:*)"
  - "Bash(bk pipeline view:*)"
  - "Bash(bk pipeline validate:*)"
  - "Bash(bk auth status:*)"
  - "Bash(bk cluster list:*)"
  - "Bash(bk cluster view:*)"
  - "Bash(bk organization list:*)"
  - "Bash(bk config list:*)"
  - "Bash(bk config get:*)"
  - "Bash(bk version:*)"
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Buildkite

Workflows for interacting with Buildkite CI using the `bk` CLI — checking
build status, investigating failures, viewing logs, and monitoring builds.

## When to Use

- Checking CI status for the current branch or PR
- Investigating why a Buildkite build failed
- Monitoring builds after a git push
- Viewing build logs or job details
- Any CI-related task (use Buildkite tools, NOT GitHub tools)

## Pre-Flight: Auth Check

**HARD RULE:** Before any `bk` command, verify authentication works:

```bash
bk build view -p <pipeline> -b main --json 2>&1 | head -3
```

If you see ANY of these errors:
- `401 Authentication required`
- `Your access token doesn't have the <scope> scope`
- `403 Forbidden`
- `Error: GET https://api.buildkite.com/...`

**Stop immediately** and tell the user:

> Buildkite CLI needs re-authentication. Please run `bk auth login` in your
> terminal to refresh credentials.

Common missing scopes:
- `read_build_logs` — needed for `bk job log`
- `read_builds` — needed for `bk build view`
- `read_organizations` — needed for listing pipelines

Do NOT attempt to configure auth, create tokens, or work around auth failures
yourself. The user must run `bk auth login` interactively.

## Checking Build Status

### Current Branch

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | \
  jq '{number: .number, state: .state, finished: .finished_at, jobs: [.jobs[] | select(.state == "failed" or .state == "broken") | {name: .name, state: .state, exit_status: .exit_status}]}'
```

### Specific Build

```bash
bk build view -p <pipeline> <build-number> --json 2>&1 | \
  jq '{state: .state, jobs: [.jobs[] | select(.type == "script") | {name: .name, state: .state, exit_status: .exit_status}]}'
```

## Understanding Build States

### Build States

| State | Meaning |
|-------|---------|
| `passed` | All jobs completed successfully |
| `failed` | One or more jobs failed |
| `failing` | Build still running but has failures |
| `running` | Build is in progress |
| `blocked` | Waiting for manual approval |
| `canceled` | Build was canceled |

### Job States

| State | Meaning |
|-------|---------|
| `passed` | Job succeeded |
| `failed` | Job failed with non-zero exit |
| `broken` | **Usually means skipped** — upstream dependency failed or conditional logic excluded it. NOT necessarily a failure. |
| `running` | Job in progress |

**Key insight:** `broken` jobs are almost never the root cause. Always
investigate `failed` jobs first.

## Viewing Job Logs

### Get Failed Job IDs

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | \
  jq -r '.jobs[] | select(.state == "failed") | "\(.id) \(.name)"'
```

### Fetch Logs

```bash
bk job log <job-uuid> -p <pipeline> -b <build-number> --no-timestamps 2>&1
```

If this returns `Your access token doesn't have the read_build_logs scope`:

> Your Buildkite token is missing the `read_build_logs` scope. Please run
> `bk auth login` to re-authenticate with the correct permissions.

**Fallback:** If logs can't be fetched after re-auth, ask the user to download
them from the Buildkite web UI and share the file for analysis.

## Investigating Failures

Follow this progressive disclosure pattern:

### Step 1: Get Overall Status

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | \
  jq '{state: .state, jobs: [.jobs[] | select(.state == "failed") | {name: .name, exit_status: .exit_status}]}'
```

### Step 2: Get Logs for Failed Jobs

For each failed job, fetch and analyze logs. Look for:
- Error messages and stack traces
- Exit codes (see common codes below)
- File paths and line numbers
- Missing dependencies or commands

### Step 3: Common CI Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 1 | General error (test failure, lint error) |
| 2 | Misuse of shell command / bats test failure |
| 17 | Docker build failed |
| 127 | Command not found |
| 137 | OOM killed |

### Step 4: Check if Pre-Existing

Compare with main branch to see if the failure is new:

```bash
bk build view -p <pipeline> -b main --json 2>&1 | \
  jq '[.jobs[] | select(.name == "<failing-step-name>") | {state: .state, exit_status: .exit_status}]'
```

## Monitoring Builds After Push

After pushing code, check the build status. Since cron-based polling of `bk`
can be unreliable (known issue with Bash tool internal errors in cron context),
prefer manual checks:

```bash
# Quick status check
bk build view -p <pipeline> -b <branch> --json 2>&1 | jq -r '.state'
```

If the build is still running, tell the user and offer to check again later.

## Pipeline Discovery

```bash
# List the repo's pipeline slug (usually matches repo name)
bk build view --json 2>&1 | jq -r '.pipeline.slug'

# View recent builds
bk build view -p <pipeline> --json 2>&1 | jq '{number: .number, state: .state, branch: .branch}'
```

## Opening in Browser

```bash
bk build view -p <pipeline> -b <branch> -w
```

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "check CI" / "build status" | Run status check for current branch |
| Build URL shared | Parse pipeline/build number, fetch details |
| "why did CI fail" | Progressive investigation: status -> logs -> analysis |
| Auth error (401/403) | **Stop.** Tell user to run `bk auth login` |
| Missing scope | **Stop.** Tell user which scope is needed, run `bk auth login` |
| After git push | Check build status, report result |

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/buildkite"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/buildkite/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:buildkite
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `buildkite/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
