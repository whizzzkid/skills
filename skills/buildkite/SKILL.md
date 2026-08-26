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
  version: "2026.08.26-181717"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Buildkite

Workflows for Buildkite CI via the `bk` CLI — status, failures, logs, monitoring.

## When to Use

- CI status for current branch or PR
- Why a Buildkite build failed
- Monitoring builds after a git push
- Viewing build logs or job details
- Any CI task → use Buildkite tools, NOT GitHub tools

## HARD RULE: investigate only your own branches

- Before debugging a PR's CI failure, verify the branch is one the agent created in this engagement (this or a prior session on the same ticket).
- Branch unfamiliar → stop. Do not investigate or change it.

```bash
gh pr view "$PR" --json headRefName,author --jq '.headRefName + " (@" + .author.login + ")"'
```

- On unfamiliar branch, tell the user and stop:
  > "PR #{N} is on `{branch}` which isn't a branch I worked on — I shouldn't
  > debug it."
- "PR #{N} is failing" is NOT authorization to touch an unrelated PR — the branch/author check gates the work, not the request.

## Auth Error Handling

Any `bk` command returning ANY of these → **stop immediately**:
- `401 Authentication required`
- `Your access token doesn't have the <scope> scope`
- `403 Forbidden`
- `Error: GET https://api.buildkite.com/...`

Tell the user:

> Buildkite CLI needs re-authentication. Please run `bk auth login` in your
> terminal to refresh credentials.

- Common missing scopes: `read_build_logs` (job logs), `read_builds` (build view), `read_organizations` (pipeline listing).
- Do NOT configure auth, create tokens, or work around auth failures. User must run `bk auth login` interactively.
- Logs unfetchable after re-auth → ask user to download from the Buildkite web UI.
- Never extract a token from the user's `bk` config/environment and call the Buildkite REST API directly via `curl` as a workaround. Token-based curl workarounds bypass scope checks, leak credentials into shell history, and have repeatedly produced multi-turn dead ends when the original failure was scope-shaped, not credential-shaped.
- `Mutation operations are not allowed` (a GraphQL-only token) is NOT a stop-case — see [Retrying a failed build](#retrying-a-failed-build) for the rebuild fallback before escalating.
- **Stop diagnosing once a failure is infra-shaped.** After ≥2 consecutive rebuilds fail with the same error string on the same step, classify as infra-side (e.g. mirror/network failure unrelated to the diff) and stop — report the pattern and recommend waiting for CI to recover. Do not list all jobs or re-diagnose; repeated identical errors across independent rebuilds add noise, not signal.

## Tool Selection

- **HARD RULE:** Use the locally-installed `bk` CLI for every Buildkite inspection. Never substitute `npx <some-buildkite-cli>` or `WebFetch` on a Buildkite URL when `bk` is available.
- Resolve once at the start of any Buildkite flow:

  ```bash
  command -v bk >/dev/null || { echo "bk CLI not on PATH — install it"; exit 1; }
  ```

- User pastes a Buildkite URL → parse `pipeline` and `build` from the path, call `bk build view -p <pipeline> <build-number>`. Build number is positional; `-b` is `--branch`, not the build number. Do NOT `WebFetch` the URL — the HTML view omits structured job data.
- Fall back to the REST API via `curl` only when `bk` is unavailable **and** the user explicitly approves.

## Pre-Flight: Auth Check

- **HARD RULE:** Before any `bk` command, verify authentication works:

  ```bash
  bk build view -p <pipeline> -b main --json 2>&1 | head -3
  ```

- Auth error → [Auth Error Handling](#auth-error-handling).

## Canonical Build Query

Pattern for inspecting a build's jobs:

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | \
  jq '{number: .number, state: .state, finished: .finished_at, \
       jobs: [.jobs[] | select(.state == "failed" or .state == "broken") | \
              {name: .name, state: .state, exit_status: .exit_status}]}'
```

- **Always strip the auth warning before `jq`.** Under env-var auth (`BUILDKITE_API_TOKEN`), `bk ... --json` prepends `Warning: using BUILDKITE_API_TOKEN ...` to **stdout**, breaking the parse with "Invalid numeric literal". Pipe through `grep -v '^Warning:'` (safe whether the line is present or not; prefer over `tail -n +2`, which corrupts interactive-auth output that has no warning). Apply to every `--json | jq` pipe.
- Adjust the `select` predicate to filter by different states.
- Target a specific build → pass the build number as a **positional** arg: `bk build view -p <pipeline> <build-number> --json`. Never pass it to `-b`.
- On `bk build view`, `-b` is `--branch`; passing a build number to it resolves to `null` → breaks the `jq` pipe with "Invalid numeric literal".
- Overload: on `bk job log`, `-b` / `--build-number` *is* the build number.

## Checking Build Status

- **Current branch:** canonical build query, selecting failed/broken jobs.
- **Specific build:** pass the build number positionally — `bk build view -p <pipeline> <build-number> --json` — filtering on `.type == "script"` jobs. Never pass the build number to `-b` (that flag selects a branch).
- **A green host-side check rollup is not per-job evidence.** The rollup carries one entry per registered check — often one for the whole pipeline — so a conditional, skipped, or soft-failed step reads as a pass. Any claim resting on a specific job's outcome ("the local failure does not reproduce in CI") needs the per-job view, cited as build number + that job's exit status:

  ```bash
  bk build view -p <pipeline> <build-number> --json 2>&1 | grep -v '^Warning:' | \
    jq -r --arg s '<step-name>' '.jobs[] | select(.name // "" | test($s)) | "\(.name) \(.state) exit=\(.exit_status)"'
  ```

- Reserve the rollup for the coarse is-the-pipeline-green gate only.
- **A check with no step renders identically to a pass.** Before reporting any named check's outcome, confirm a matching job exists in the job list — an empty match is a **finding** ("that check does not run here"), never a pass. A build can be green precisely *because* an unwired check never ran.

  ```bash
  bk build view -p <pipeline> <build-number> --json 2>&1 | grep -v '^Warning:' | \
    jq -r --arg s '<step-name>' '[.jobs[] | select(.name // "" | test($s))] | length'
  ```

  - **Guard the name with `// ""`.** A null-named job (waiter/block steps) aborts `test()` at jq rc=5 with *no* stdout — a presence probe reads that as zero. Fails **open**, indistinguishable from real absence.
  - Count `0` → grep the repo for the tool's wiring (pipeline definition, CI workflow dir, setup TODO) and report an **unwired gate**, never a green result. A config file present in the repo is not wiring; something must invoke it.

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

**Key insight:** `broken` jobs are almost never the root cause. Always investigate `failed` jobs first.

## Viewing Job Logs

- **Get failed job IDs:** canonical build query with filter `.jobs[] | select(.state == "failed") | "\(.id) \(.name)"`.
- **Fetch logs:**

  ```bash
  bk job log <job-uuid> -p <pipeline> -b <build-number> --no-timestamps 2>&1
  ```

  Auth/scope error → [Auth Error Handling](#auth-error-handling).

## HARD RULE: never predict build outcomes

Never state or imply a build will pass ("should pass," "this should fix it")
without fetching the actual result. After every CI-directed push, explicitly
fetch and report the build/job state — treat an unfetched build as unknown.
A pushed fix does not mean the build will pass; CI has multiple independent
gates.

## HARD RULE: check branch currency before diagnosing failures

Before attributing a CI failure to infra or the diff, check
`git rev-list --count origin/main..HEAD` (or `gh pr view --json behindBy`).
A branch behind main is more likely to cause build failures than a transient
infra issue — sync first, rebuild second.

## Investigating Failures

Progressive disclosure pattern:

1. **Overall status:** canonical build query, selecting only `failed` jobs, extracting `{name, exit_status}`.
2. **Logs for failed jobs:** fetch and analyze. Look for error messages/stack traces, exit codes (below), file paths/line numbers, missing dependencies or commands.
3. **Classify infra vs. code** (below) *before* attributing the failure to the diff.
4. **Common CI exit codes** (below).
5. **Check if pre-existing:** canonical build query against `-b main`, selecting the specific failing step by name.
6. **Report trigger and cause separately:** when the build was triggered by the user's merge/push but the failure is unrelated to their diff, state both facts explicitly — "Build #N was triggered by your merge; the failure in step X is [pre-existing / infra / flaky], not caused by your diff." Never collapse into a single "unrelated" verdict — omitting the trigger acknowledgment contradicts the user's correct observation that their action started the build.

### HARD RULE: classify infra vs. code before attributing a red build to the diff

An agent-side failure is reported under the **step's own name** with a synthetic
exit status, so the GitHub check list and `bk build view` render it identically to
a genuine test failure — step name plus a plausible non-zero status. Only the log
body separates them. Read it before bisecting anything.

- The tell is **position**: the failure prints *before* the step's command runs.
  A failure inside the agent's own environment hook never reached your code.
- Treat any of these markers as infrastructure — retry, do not touch the diff:
  - `Error setting up job executor` / `job_executor_error`
  - `updating command exit code -1`
  - any failure inside `Running agent environment hook` or a `pre-exit` hook
  - agent lost / instance terminated / unhealthy-instance indicators
- Retry the **single job**, not the whole build — `bk job retry <job-uuid>`; token
  caveat and the `bk build rebuild` fallback live in
  [Retrying a failed build](#retrying-a-failed-build).
- Only once the log shows the step's command actually executed does the failure
  read as signal about the change.
- Retry succeeded with no code change → that *is* the classification, recorded.
  Retry fails identically twice → infra-side but not transient; stop diagnosing
  per [Auth Error Handling](#auth-error-handling).
- Reading a raw REST log payload instead (only under [Tool Selection](#tool-selection)) →
  strip ANSI escapes **and** inline `_bk;t=<epoch-ms>` timestamp markers first;
  the tail is unreadable with either left in.

### Common CI Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 1 | General error (test failure, lint error) |
| 2 | Misuse of shell command / bats test failure |
| 17 | Docker build failed |
| 127 | Command not found |
| 137 | OOM killed |
| 143 | SIGTERM — job killed (spot-instance reclaim / agent shutdown). If the step's real work already printed success, treat as infra noise, not a code failure: rebuild once, do not diagnose the diff. |
| 255 / -1 | Synthetic, not the command's own status — an agent-side setup failure is stamped with it under the step's name. Classify from the log (above) before reading it as a code failure. |

## Reading upstream step status from a downstream step

When a downstream step must branch on whether an upstream step passed, failed, or timed out, use the platform's native step-outcome API:

```bash
buildkite-agent step get "outcome" --step "<step-key>"
# returns: passed | failed | soft_failed | timed_out | broken
```

- Use `buildkite-agent step get "outcome"` — written by the agent itself, available regardless of how the upstream step terminated.
- Reject sentinel files, marker artifacts, or any side-effect file written by the upstream step's own code as a status signal. If the step crashes before its cleanup trap runs, the sentinel is never written and the downstream step has no signal — exactly the failure case the detection exists for.
- Reject `buildkite-agent artifact search` as a status proxy for the same reason; artifact presence is a side effect of the step's code path, not a platform-written outcome.
- Before designing any cross-step status detection, grep the repo for existing `buildkite-agent step` usage and check the Buildkite agent CLI reference for first-class APIs.

## Monitoring Builds After Push

Cron-based polling of `bk` is unreliable → prefer a manual check:

```bash
# Quick status check
bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | jq -r '.state'
```

- Build still running → tell the user and offer to check again later.
- **HARD RULE: never foreground-poll.** Do not run an `until`/`while` loop on `bk build view` in the foreground — it blocks the turn (often 5–10 min) and forces the user to interrupt to regain control. Run a single status check and report state. If a watch is genuinely needed, run it with `run_in_background: true`.
- **HARD RULE: a monitoring announcement states URL + failing step + next action — never just "monitoring in background."** A bare "watching CI" leaves the user unable to tell whether the failure is already identified or still being discovered, forcing an interrupt. Immediately after starting a watch, report all three:
  - build URL — `bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | jq -r '.web_url'`
  - the current failing step (if already known), and
  - the next diagnostic action. Example: "Build #N running — {URL}. Watching the RuboCop and spec steps; will fetch logs on first failure."
- **Non-required checks do not gate a merge.** Informational checks (security scanners, dependency bots) often queue indefinitely. Never block or keep polling on them — gate only on GitHub *required* checks via `gh pr checks --json name,state,required | jq 'select(.required==true)'` (pr-merge Step 2 owns this).

## Pipeline Discovery

```bash
# List the repo's pipeline slug (usually matches repo name)
bk build view --json 2>&1 | jq -r '.pipeline.slug'

# View recent builds
bk build view -p <pipeline> --json 2>&1 | jq '{number: .number, state: .state, branch: .branch}'
```

## Cancelling Builds

**From within a running build (self-cancel):** a step inside a Buildkite agent can cancel its own build without an external API token:

```bash
buildkite-agent build cancel
```

- Right tool when a guard step detects a condition that should abort the pipeline (wrong branch, missing prerequisite, duplicate build). The agent binary is always present in the build environment → no extra auth setup.

**From outside the build (external cancel):** use the Buildkite REST API:

```bash
curl -s -X PUT \
  "https://api.buildkite.com/v2/organizations/{org}/pipelines/{pipeline}/builds/{build_number}/cancel" \
  -H "Authorization: Bearer $BUILDKITE_TOKEN"
```

- Replace `{org}`, `{pipeline}`, `{build_number}` with actual values. Requires a token with the `write_builds` scope.

## Retrying a failed build

- `bk job retry <id>` needs a REST-mutation-capable token. A GraphQL-scoped token fails with "This API access token only allows GraphQL queries. Mutation operations are not allowed."
- That error is NOT a full auth failure — the token still has read access. Try the build-level rebuild first (a different endpoint that may succeed with the same token):

  ```bash
  bk build rebuild <build-number> -p <pipeline> -y
  ```

- `bk job retry` takes only `<job-uuid>` — no pipeline flag:
  ```bash
  bk job retry <job-uuid> --yes --no-pager
  ```
- Mutation token unavailable + logs confirm infrastructure-only failure (pre-command) → signed empty CI-retry commit:
  ```bash
  git commit --allow-empty -m "ci: retry infra failure"
  ```
  Use only when the failure occurred before repo commands ran and the PR will squash-merge.
- Escalate to `bk auth login` only if `bk build rebuild` also fails.

### Artifact download auth conflict

`bk artifacts download` forwards its bearer token to presigned S3 redirect
URLs, causing S3 to reject with dual-auth. Workaround: request the redirect
without following it, then follow the returned URL without an Authorization
header — or download from the Buildkite web UI.

## Adding env vars to a CI pipeline

A new env var must be present at **every** forwarding layer or it is silently dropped before reaching the container.

| Layer | Where to set | Example |
|-------|-------------|---------|
| Pipeline definition | `env:` block in `pipeline.yml` | `env:\n  MY_VAR: "value"` |
| Pipeline build script | plugin `env:` array in `pipeline.rb` | `env: ["MY_VAR"]` |
| Compose definition | `environment:` in `docker-compose.yml` | `environment:\n  - MY_VAR` |
| Container image | `ENV` in `Dockerfile` | `ENV MY_VAR=""` |

- Walk every layer when adding or renaming a var.
- Where the pipeline build script has a spec, add `expect(config['env']).to include('VAR')` so a future omission is caught by tests, not a silently-broken build.

## Pinning a CI step to a mirrored image

An internal registry mirror may be **pre-seeded**, not pull-through — referencing a new image path fails at `docker pull` with "repository does not exist in the registry" even when sibling `library/*` images resolve.

- Verify the exact repository exists under the mirror before pinning a step to it — do not assume other working `library/*` images prove a pull-through cache.
- Repo absent → reuse an image already referenced in the pipeline and install the extra toolchain into it, pinned + checksummed.

## Build URL vs Opening in Browser

- **To retrieve a build URL** (to share or link), read it from JSON — never `-w`:

  ```bash
  bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | jq -r '.web_url'
  ```

- **Reserve `-w` / `--web` for when the user explicitly asks to open the build** — it launches the default browser immediately as a side effect, not a URL-retrieval flag:

  ```bash
  bk build view -p <pipeline> -b <branch> -w
  ```

- Never run `-w` just to obtain a URL → it opens an unexpected browser tab.

## Canonical download path

When saving any Buildkite artifact to disk — build JSON, job logs, artifact files — write to a structured, namespaced path rather than an ad-hoc `/tmp/<name>`. Follows the `/tmp/agent/<tool>/...` convention shared by wk-gh (see it for the rationale).

```
/tmp/agent/buildkite/<build_number>/<job_id>/<filename>
```

| Resource | Example path |
|---|---|
| Build JSON | `/tmp/agent/buildkite/<build>/build.json` |
| Job log | `/tmp/agent/buildkite/<build>/<job_id>/log.txt` |
| Artifact | `/tmp/agent/buildkite/<build>/<job_id>/artifacts/<file>` |

- `mkdir -p` the directory before writing.
- Why: namespaces parallel investigations across builds, prevents cross-session overwrites of identically-named scratch files (e.g., two `/tmp/rubocop.log` clobbering each other), and gives a greppable audit trail (`ls /tmp/agent/buildkite/`).

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "check CI" / "build status" | Run status check for current branch |
| Build URL shared | Parse pipeline/build number, fetch details |
| "why did CI fail" | Progressive investigation: status -> logs -> analysis |
| Auth error (401/403) | **Stop.** Tell user to run `bk auth login` |
| `bk job retry` "mutation not allowed" | Try `bk build rebuild <n> -p <pipeline> -y` before escalating |
| Missing scope | **Stop.** Tell user which scope is needed, run `bk auth login` |
| After git push | Check build status, report result |
| Cancel from within a build | `buildkite-agent build cancel` (no token needed) |
| Cancel from outside a build | REST API `PUT .../builds/{n}/cancel` with `write_builds` token |
| Claim rests on one specific job | Per-job view; cite build number + that job's `exit_status`, never the rollup |
| "Did check X pass?" | Confirm a matching job exists first — no match = unwired gate, a finding, not a pass |
| Log shows `job_executor_error` / env-hook failure | Infra, not the diff — `bk job retry <job-uuid>`, leave the code alone |
| Post-merge build fails, failure unrelated to diff | State trigger ("your merge started this build") AND cause ("failure is pre-existing/infra") separately |
| Saving any `bk` payload to disk | Use `/tmp/agent/buildkite/<build>/...` |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn buildkite`).
