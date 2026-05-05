---
name: wk-buildkite
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
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.04-232313'
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
can be unreliable, prefer manual checks:

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

## Cancelling Builds

### From within a running build (self-cancel)

A step running inside a Buildkite agent can cancel its own build without an
external API token. Use the agent CLI subcommand:

```bash
buildkite-agent build cancel
```

This is the right tool when a guard step detects a condition that should abort
the pipeline (e.g., wrong branch, missing prerequisite, duplicate build). The
agent binary is always present in the build environment so no additional auth
setup is needed.

### From outside the build (external cancel)

To cancel a build from outside the agent (e.g., from a script or another
system), use the Buildkite REST API:

```bash
curl -s -X PUT \
  "https://api.buildkite.com/v2/organizations/{org}/pipelines/{pipeline}/builds/{build_number}/cancel" \
  -H "Authorization: Bearer $BUILDKITE_TOKEN"
```

Replace `{org}`, `{pipeline}`, and `{build_number}` with the actual values.
This requires a token with the `write_builds` scope.

## Opening in Browser

```bash
bk build view -p <pipeline> -b <branch> -w
```

## Canonical download path

When saving any Buildkite artifact to disk — build JSON, job logs,
artifact files — write to a structured, namespaced path rather than an
ad-hoc `/tmp/<name>`. This follows the same `/tmp/agent/<tool>/...`
convention used by wk-gh (see wk-gh for the rationale).

```
/tmp/agent/buildkite/<build_number>/<job_id>/<filename>
```

| Resource | Example path |
|---|---|
| Build JSON | `/tmp/agent/buildkite/<build>/build.json` |
| Job log | `/tmp/agent/buildkite/<build>/<job_id>/log.txt` |
| Artifact | `/tmp/agent/buildkite/<build>/<job_id>/artifacts/<file>` |

Run `mkdir -p` on the directory before writing. The structure namespaces
parallel investigations across multiple builds, prevents cross-session
overwrites of identically-named scratch files (e.g., two `/tmp/rubocop.log`
files clobbering each other), and provides a greppable audit trail
(`ls /tmp/agent/buildkite/`).

This convention is shared across every skill that downloads from an
external system — see `wk-gh` for the matching path.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "check CI" / "build status" | Run status check for current branch |
| Build URL shared | Parse pipeline/build number, fetch details |
| "why did CI fail" | Progressive investigation: status -> logs -> analysis |
| Auth error (401/403) | **Stop.** Tell user to run `bk auth login` |
| Missing scope | **Stop.** Tell user which scope is needed, run `bk auth login` |
| After git push | Check build status, report result |
| Cancel from within a build | `buildkite-agent build cancel` (no token needed) |
| Cancel from outside a build | REST API `PUT .../builds/{n}/cancel` with `write_builds` token |
| Saving any `bk` payload to disk | Use `/tmp/agent/buildkite/<build>/...` |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn buildkite`).
