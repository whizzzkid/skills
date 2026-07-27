---
class: principle
date: 2026-07-27
severity: medium
---

# An agent-side failure wears the step's own name

**Rule** — before attributing a red Buildkite build to the diff, read the failing
job's log and classify it. A failure in the agent's environment hook is reported
under the **step's** name with a synthetic exit status (255, or `-1` after the
agent's own post-processing), so the GitHub check list and `bk build view` render
it identically to a genuine test failure. Markers that mean infrastructure —
retry the single job, leave the code alone:

- `Error setting up job executor` / `job_executor_error`
- `updating command exit code -1`
- any failure inside `Running agent environment hook` or a `pre-exit` hook
- agent lost / instance terminated / unhealthy-instance indicators

**Why** — the step name and a plausible non-zero status are the two signals a
bisect decision normally rests on, and both are counterfeit here. Only the log
body distinguishes them, and the tell is *position*: the failure prints before
the step's command ever ran. A single-job retry going green with no code change
is the confirmation.

**Where** — `skills/buildkite/SKILL.md` → Investigating Failures → "HARD RULE:
classify infra vs. code before attributing a red build to the diff", plus the
`255 / -1` row in Common CI Exit Codes and a Quick Reference row.

## Rejected from the source report

The report's suggested fix prescribed `curl` against the Buildkite REST API for
both the job list and the retry. That contradicts this skill's standing HARD RULE
(`bk` CLI for every inspection; REST only when `bk` is unavailable *and* the user
approves) and its explicit ban on extracting a token for a curl workaround. The
principle was folded in `bk`-native terms instead — `bk job retry <job-uuid>`,
with the existing GraphQL-token caveat and `bk build rebuild` fallback
cross-referenced rather than restated. The report's one durable REST detail was
kept and scoped to the approved-fallback path only: a raw log payload carries
ANSI escapes *and* inline `_bk;t=<epoch-ms>` markers, and both must be stripped
before the tail is readable.

## Not escalated

The pre-existing exit-code 143 row (SIGTERM / spot reclaim) and the Auth Error
Handling "stop after ≥2 identical rebuild failures" rule are adjacent but neither
covers first-look classification of a pre-command failure, so this is a coverage
gap filled, not a rule that failed.
