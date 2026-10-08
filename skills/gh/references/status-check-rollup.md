# Reading statusCheckRollup

Applies to **every** rollup consumer — `gh pr checks --watch`, a hand-rolled `until`
poll, or a one-shot readiness check. Reach this section from any of them; the union
rules are not `--watch`-specific.

- **Important — `statusCheckRollup` is a heterogeneous union; inspect BOTH state
  fields.** CheckRun nodes expose `.status`/`.conclusion`; legacy commit Status nodes
  expose `.state` and have `.status == null`. A predicate over one field silently
  passes a pending entry of the other type: `select(.status != null)` drops every
  status context, so an external provider posting commit statuses never gates the
  poll and a still-building PR reads as green.
  - Non-terminal when `.status ∈ {QUEUED,IN_PROGRESS,PENDING}` **OR** `.state == "PENDING"`.
  - Failing when `.conclusion ∈ {FAILURE,TIMED_OUT}` **OR** `.state ∈ {FAILURE,ERROR}`; `CANCELLED` uses the
    same-head replacement rule below.
  - Never gate on `.status` alone.

  ```bash
  gh pr view --json headRefOid,statusCheckRollup \
    --jq '{head: .headRefOid,
           pending: [.statusCheckRollup[] | select(.status // .state | IN("QUEUED","IN_PROGRESS","PENDING"))] | length}'
  ```

- **Report with coalescing fallbacks** — project `{n: (.name // .context), r: (.conclusion // .state)}`.
  An entry rendering all-null through check-run field names
  (`{name:null,status:null,conclusion:null}`) is a status context read through the
  wrong shape — re-read the raw rollup; it is never evidence of an empty gate.

### Superseded same-head runs

- **A cancelled current-HEAD GitHub Actions check is not terminal while a newer same-workflow run is live.**
  Resolve the cancelled run ID from `detailsUrl`, read its `workflow_id`, list runs filtered by `head_sha`, then
  poll the newest matching workflow:
  ```bash
  gh api repos/{owner}/{repo}/actions/runs/{cancelled_run_id} \
    --jq '{id, workflow_id, head_sha}'
  gh api --method GET repos/{owner}/{repo}/actions/runs \
    -f head_sha="{head_sha}" \
    --jq '.workflow_runs[] | {id, workflow_id, status, conclusion, created_at}'
  ```
- Newer match in `queued`, `requested`, `waiting`, `pending`, or `in_progress` → ignore the older
  cancellation and wait for the replacement's terminal conclusion.
- No newer match, or newest match ends non-passing → treat the cancellation as failure.

## `gh pr checks --watch` is not proof of green

`gh pr checks --watch` can return when a *subset* of checks resolves (a fast
check finishes) while others are still `PENDING`/`IN_PROGRESS` — its exit is not
a terminal-state guarantee. A single watch is not proof of green CI.

- After the watch exits, re-query the full rollup and confirm every check is
  terminal before treating CI as green — apply the union rules above.
- **The rollup is one entry per registered check, not one per pipeline job.** A
  single entry can cover an entire pipeline, so a green rollup cannot distinguish
  "that job passed" from "that job never ran / was skipped / soft-failed." Gate the
  coarse is-the-pipeline-green question on the rollup; any claim resting on a
  *specific* job's outcome must cite the CI provider's per-job view and that job's
  exit status.
- **Confirm the rollup's `headRefOid` equals the pushed tip before trusting its
  state.** Webhook propagation lags a push, so the rollup (and a `--watch` exit)
  can report the *prior* commit entirely — a staleness axis distinct from the
  subset-resolve above. Compare `.headRefOid` against `git ls-remote origin
  <branch>`; on mismatch, re-query until it catches up, or fall back to the CI
  provider's build-by-branch query (ground truth for the current commit).
- Re-issue the watch if any check is still pending.

## `gh pr checks --json` is not the rollup schema

- Fields: `bucket, completedAt, description, event, link, name, startedAt, state,
  workflow` — no `.status`/`.conclusion`, so the union predicate above does not
  transfer. Probe the set (`gh pr checks --help`) first; an unsupported name is a
  usage error, not an empty gate.
- Prefer `bucket` over hand-classifying `state` — it collapses to
  `pass|fail|pending|skipping|cancel`. Exit code `8` means checks pending.
- `--required` filters to policy-required checks that **posted**; one that never
  ran is absent here too, so it never replaces `required - observed` below.

## A green-checks BLOCKED merge — what to check

- `mergeStateStatus: BLOCKED` with every visible check green → compare the
  active ruleset's `required_status_checks` contexts against HEAD's full
  `statusCheckRollup` names (`.name // .context`). A missing context is the
  blocker even though nothing is red.
- Read ruleset requirements from `repos/{owner}/{repo}/rulesets/{id}`. Do not
  substitute `branches/{branch}/protection`; ruleset-governed branches can
  return 404 there while still enforcing required contexts.
- **`BLOCKED` ≠ branch-behind.** Branch-freshness requires
  `strict_required_status_checks_policy: true` in the ruleset; absent it,
  passing checks + resolved conversations = mergeable regardless of distance
  from base. Check the flag before attributing BLOCKED to staleness.
- Confirm rollup entries belong to `headRefOid`; use
  `repos/{owner}/{repo}/commits/{head_sha}/check-runs` to inspect check-run
  provenance. Compute `required - observed` explicitly.
- **`required_signatures` covers the whole commit range, not the head.** Head
  `verified: true` while one mid-range commit is unsigned still blocks. Check every
  commit before ruling the signing policy out:

  ```bash
  gh api "repos/{owner}/{repo}/pulls/{n}/commits" \
    --jq '.[] | select(.commit.verification.verified == false)
          | {sha, reason: .commit.verification.reason}'
  ```

- Remediation for a blocker you cannot satisfy directly:
  [`merge-blocker-diagnosis.md`](merge-blocker-diagnosis.md).

## A run must prove the pull-request gate

- Confirm the workflow's `on:` accepts the current ref and a run exists before marking an edited job complete or
  required. Zero runs → inspect the trigger block, create an accepted ref or PR, then read that run's logs. See
  [trigger verification details](2026-07-28_workflow-run-must-exist-for-ref.md).
- Treat a successful `workflow_dispatch` run as execution evidence only. Gate merge readiness on the live PR's
  `headRefOid`, `statusCheckRollup`, and `mergeStateStatus`; dispatched check-runs do not prove the PR-required
  contexts were populated.
- Expect `pull_request` runs from a PR created or updated with the repository `GITHUB_TOKEN` to await approval for
  `opened`, `synchronize`, and `reopened`. Surface **Approve workflows to run**; never substitute dispatch success.
- Need unattended PR-context CI → create or update the PR with a GitHub App installation token or personal access
  token instead of the repository `GITHUB_TOKEN`.
