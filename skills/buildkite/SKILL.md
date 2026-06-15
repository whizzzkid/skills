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
group: tools
metadata:
  author: whizzzkid
  version: '2026.06.15-190033'
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

## HARD RULE: investigate only your own branches

Before debugging a PR's CI failure, verify the PR's branch is one the agent
created in this engagement (this session or a prior session on the same
ticket). When it is not, stop — do not investigate or change it.

```bash
gh pr view "$PR" --json headRefName,author --jq '.headRefName + " (@" + .author.login + ")"'
```

- When the branch is unfamiliar, tell the user and stop:
  > "PR #{N} is on `{branch}` which isn't a branch I worked on — I shouldn't
  > debug it."
- A user saying "PR #{N} is failing" is not authorization to touch an
  unrelated PR — the branch/author check gates the work, not the request.

## Auth Error Handling

If any `bk` command returns ANY of these errors:
- `401 Authentication required`
- `Your access token doesn't have the <scope> scope`
- `403 Forbidden`
- `Error: GET https://api.buildkite.com/...`

**Stop immediately** and tell the user:

> Buildkite CLI needs re-authentication. Please run `bk auth login` in your
> terminal to refresh credentials.

Common missing scopes: `read_build_logs` (job logs), `read_builds` (build
view), `read_organizations` (pipeline listing).

Do NOT attempt to configure auth, create tokens, or work around auth failures
yourself. The user must run `bk auth login` interactively. If logs can't be
fetched after re-auth, ask the user to download them from the Buildkite web UI.

- Never extract a token from the user's `bk` config / environment and call
  the Buildkite REST API directly via `curl` as a workaround. Token-based
  curl workarounds bypass scope checks, leak credentials into shell history,
  and have repeatedly produced multi-turn dead ends when the original auth
  failure was scope-shaped, not credential-shaped.

## Tool Selection

**HARD RULE:** Use the locally-installed `bk` CLI for every Buildkite
inspection. Never substitute `npx <some-buildkite-cli>` or `WebFetch` on a
Buildkite URL when `bk` is available.

- Resolve once at the start of any Buildkite flow:

  ```bash
  command -v bk >/dev/null || { echo "bk CLI not on PATH — install it"; exit 1; }
  ```

- When the user pastes a Buildkite URL, parse `pipeline` and `build` from
  the path and call `bk build view -p <pipeline> <build-number>` — the build
  number is a positional argument; `-b` is `--branch`, not the build number.
  Do not `WebFetch` the URL — the HTML view omits structured job data.
- Fall back to the REST API via `curl` only when `bk` is unavailable **and**
  the user explicitly approves the fallback.

## Pre-Flight: Auth Check

**HARD RULE:** Before any `bk` command, verify authentication works:

```bash
bk build view -p <pipeline> -b main --json 2>&1 | head -3
```

If this returns an auth error, follow the [Auth Error Handling](#auth-error-handling)
guidance above.

## Canonical Build Query

Use this pattern whenever you need to inspect a build's jobs:

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | \
  jq '{number: .number, state: .state, finished: .finished_at, \
       jobs: [.jobs[] | select(.state == "failed" or .state == "broken") | \
              {name: .name, state: .state, exit_status: .exit_status}]}'
```

Adjust the `jq` filter for the specific need (change the `select` predicate
to filter by different states). To target a specific build, pass the build
number as a **positional** argument — `bk build view -p <pipeline>
<build-number> --json` — never pass it to `-b`. On `bk build view`, `-b` is
`--branch`; passing a build number to it resolves to `null`, which breaks the
`jq` pipe with "Invalid numeric literal". (Note the overload: on `bk job log`,
`-b` / `--build-number` *is* the build number.)

## Checking Build Status

### Current Branch

Use the canonical build query (see above), selecting failed/broken jobs.

### Specific Build

Pass the build number positionally — `bk build view -p <pipeline>
<build-number> --json` — filtering on `.type == "script"` jobs. Never pass
the build number to `-b` (that flag selects a branch).

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

Use the canonical build query (see above) with `.jobs[] | select(.state ==
"failed") | "\(.id) \(.name)"` as the filter.

### Fetch Logs

```bash
bk job log <job-uuid> -p <pipeline> -b <build-number> --no-timestamps 2>&1
```

If this returns an auth/scope error, follow [Auth Error Handling](#auth-error-handling).

## Investigating Failures

Follow this progressive disclosure pattern:

### Step 1: Get Overall Status

Use the canonical build query (see above), selecting only `failed` jobs and
extracting `{name, exit_status}`.

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

Use the canonical build query (see above) against `-b main`, selecting the
specific failing step by name.

## Reading upstream step status from a downstream step

When a downstream step needs to branch on whether an upstream step
passed, failed, or timed out, use the platform's native step-outcome
API.

```bash
buildkite-agent step get "outcome" --step "<step-key>"
# returns: passed | failed | soft_failed | timed_out | broken
```

- Use `buildkite-agent step get "outcome"` — written by the agent
  itself, available regardless of how the upstream step terminated.
- Reject sentinel files, marker artifacts, or any side-effect file
  written by the upstream step's own code as a status signal. If
  the step crashes before its cleanup trap runs, the sentinel is
  never written and the downstream step has no signal — exactly
  the failure case the detection exists for.
- Reject `buildkite-agent artifact search` as a status proxy for
  the same reason; artifact presence is a side effect of the
  step's code path, not a platform-written outcome.
- Before designing any cross-step status detection, grep the repo
  for existing `buildkite-agent step` usage and check the
  Buildkite agent CLI reference for first-class APIs.

## Monitoring Builds After Push

After pushing code, check the build status. Since cron-based polling of `bk`
can be unreliable, prefer manual checks:

```bash
# Quick status check
bk build view -p <pipeline> -b <branch> --json 2>&1 | jq -r '.state'
```

If the build is still running, tell the user and offer to check again later.

**HARD RULE: never foreground-poll.** Do not run an `until`/`while` loop on
`bk build view` in the foreground — it blocks the turn (often 5–10 min) and
forces the user to interrupt to regain control. Run a single status check and
report state. If a watch is genuinely needed, run it with `run_in_background:
true`.

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

## Adding env vars to a CI pipeline

A new env var must be present at **every** forwarding layer or it is silently
dropped before reaching the container.

| Layer | Where to set | Example |
|-------|-------------|---------|
| Pipeline definition | `env:` block in `pipeline.yml` | `env:\n  MY_VAR: "value"` |
| Pipeline build script | plugin `env:` array in `pipeline.rb` | `env: ["MY_VAR"]` |
| Compose definition | `environment:` in `docker-compose.yml` | `environment:\n  - MY_VAR` |
| Container image | `ENV` in `Dockerfile` | `ENV MY_VAR=""` |

Walk every layer when adding or renaming a var. Where the pipeline build
script has a spec, add `expect(config['env']).to include('VAR')` so a future
omission is caught by tests, not a silently-broken build.

## Pinning a CI step to a mirrored image

An internal registry mirror may be **pre-seeded**, not pull-through —
referencing a new image path fails at `docker pull` with "repository does
not exist in the registry" even when sibling `library/*` images resolve.

- Verify the exact repository exists under the mirror before pinning a
  step to it — do not assume other working `library/*` images prove a
  pull-through cache.
- When the repo is absent, reuse an image already referenced in the
  pipeline and install the extra toolchain into it, pinned + checksummed.

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
