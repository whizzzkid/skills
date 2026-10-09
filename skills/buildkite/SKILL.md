---
name: wk-buildkite
description: >-
  Use when working with Buildkite CI — checking build status, investigating
  failures, viewing job logs, or monitoring builds after push. Activates on
  Buildkite URLs or `bk` CLI operations. Use this instead of GitHub tools for
  CI status.
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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Buildkite

Use the `bk` CLI for all CI tasks instead of GitHub tools.

## Pre-flight

- **HARD RULE: investigate only your own branches.** Verify the branch is one you created before debugging; unfamiliar →
  stop:
  ```bash
  gh pr view "$PR" --json headRefName,author --jq '.headRefName + " (@" + .author.login + ")"'
  ```
- **HARD RULE:** Use the local `bk` CLI for every inspection — never `npx` or `WebFetch` on Buildkite URLs when `bk` is
  available. Verify once: `command -v bk >/dev/null || { echo "bk CLI not on PATH"; exit 1; }`
- **HARD RULE:** Before any `bk` command, verify auth: `bk build view -p <pipeline> -b main --json 2>&1 | head -3`.
- **HARD RULE: strip warning prefix on every `--json | jq` pipe** — `grep -v '^Warning:'`.
- URL pasted → parse pipeline/build from path, use `bk build view`. Specific build → positional:
  `bk build view -p <pipeline> <build-number> --json`. On `bk build view`, `-b` = `--branch`; on `bk job log`, `-b` =
  `--build-number`.
- Pipeline slug: `bk build view --json 2>&1 | jq -r '.pipeline.slug'`. Build URL: `jq -r '.web_url'`; use `-w`/`--web`
  only when the user explicitly asks to open the browser.
- Downloads: write to `/tmp/agent/buildkite/<build_number>/<job_id>/<filename>`; `mkdir -p` first.

## Auth errors

Any `bk` command returning 401/403/scope-missing/`Error: GET https://api.buildkite.com` → **stop**; tell the user to run
`bk auth login`. Never configure auth, create tokens, or extract tokens from config for curl workarounds. Exception:
`Mutation operations are not allowed` is NOT a stop-case → try `bk build rebuild` first. ≥2 consecutive rebuilds with
identical error → classify as infra-side, stop diagnosing.

## Checking build status

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | \
  jq '{number: .number, state: .state, finished: .finished_at, \
       jobs: [.jobs[] | select(.state == "failed" or .state == "broken") | \
              {name: .name, state: .state, exit_status: .exit_status}]}'
```

- Current branch: canonical query above. Specific build: positional build number, filter `.type == "script"` jobs.
- **Rollup is not per-job evidence** — use per-job view for specific job claims:
  ```bash
  bk build view -p <pipeline> <build-number> --json 2>&1 | grep -v '^Warning:' | \
    jq -r --arg s '<step-name>' '.jobs[] | select(.name // "" | test($s)) | "\(.name) \(.state) exit=\(.exit_status)"'
  ```
- **No matching job = unwired gate, not a pass.** Guard name with `// ""` (null-named jobs abort `test()`). Count 0 →
  grep repo for wiring, report unwired.
- States: [references/build-job-states.md](references/build-job-states.md). `broken` jobs are almost never root cause —
  investigate `failed` first.
- Upstream step status inside a build: `buildkite-agent step get "outcome" --step "<step-key>"`
  (`passed|failed|soft_failed|timed_out|broken`); never use sentinel files or artifact searches as proxies (crash before
  cleanup → no signal).

## HARD RULE: never predict build outcomes

Never state a build will pass without fetching the actual result. After every push, fetch and report state.

## Investigating failures

**HARD RULE: check branch currency before diagnosing failures** — `git rev-list --count origin/main..HEAD`; branch
behind main → sync first, rebuild second.

1. Overall status → canonical query, failed jobs only.
2. Fetch + analyze logs: `bk job log <job-uuid> -p <pipeline> -b <build-number> --no-timestamps 2>&1`. Raw REST logs →
   strip ANSI escapes AND `_bk;t=<epoch-ms>` markers first.
3. **HARD RULE: classify infra vs. code before attributing a red build to the diff** — read the log body; infra markers
   (retry, never touch the diff):
   `Error setting up job executor`, `job_executor_error`, `exit code -1`,
   `Running agent environment hook` failures, agent lost/terminated.
   Retry single job: `bk job retry <job-uuid>`; retry succeeds = classification done.
4. Check if pre-existing: canonical query against `-b main`.
5. **Report trigger AND cause separately** — "Build #N triggered by your merge;
   failure in step X is pre-existing/infra, not your diff."

## Monitoring after push

```bash
bk build view -p <pipeline> -b <branch> --json 2>&1 | grep -v '^Warning:' | jq -r '.state'
```

- **HARD RULE: never foreground-poll** (no `until`/`while` on `bk build view`) — run one check, report state; background
  with `run_in_background: true` if needed.
- **HARD RULE: a monitoring announcement states URL + failing step + next action — never just "monitoring in
  background."**
- Non-required checks do not gate merge — gate on
  `gh pr checks --json name,state,required | jq 'select(.required==true)'`.

## Cancelling and retrying

- Cancel from within: `buildkite-agent build cancel` (no token). From outside: REST `PUT .../builds/{n}/cancel` with
  `write_builds` token.
- Retry: take the first that works: 1) `bk job retry <job-uuid> --yes --no-pager` (no pipeline flag; needs REST-mutation
  token) 2) GraphQL-only → `bk build rebuild <n> -p <pipeline> -y` 3) mutation unavailable + infra failure →
  `git commit --allow-empty -m "ci: retry infra failure"`. Escalate to `bk auth login` only if rebuild also fails.
- `bk artifacts download` forwards the bearer token to S3 presigned URLs → dual-auth rejection: download from the web UI
  instead.

## CI pipeline config

- New env var: set at **every** forwarding layer or it is silently dropped — `env:` in `pipeline.yml`, plugin `env:`
  array in `pipeline.rb`, `environment:` in `docker-compose.yml`, `ENV` in `Dockerfile`. Add
  `expect(config['env']).to include('VAR')` in pipeline specs.
- Mirrored image: internal mirrors may be pre-seeded, not pull-through — verify the exact repo exists before pinning;
  absent → reuse an existing pipeline image + install toolchain.

---

## Post-Completion

Invoke `wk-learn buildkite`.
