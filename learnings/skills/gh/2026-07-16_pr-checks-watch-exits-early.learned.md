---
skill: wk-gh
date: 2026-07-16
type: gap
severity: medium
---

`gh pr checks --watch` returns before all checks resolve, so a single watch is not proof of green CI.

**What happened:** During a PR post-creation CI poll, `gh pr checks --watch`
exited as soon as a subset of checks resolved (a fast security check finished)
while a slower pipeline check was still `pending`. Treating the watch's exit as
"CI complete" would have marked the PR ready on an incomplete rollup. The watch
had to be re-issued twice and the full `statusCheckRollup` re-confirmed before
any HEAD was treated as green.

**Root cause:** `gh pr checks --watch` can terminate on partial resolution
rather than blocking until every check reaches a terminal state; the CI-poll
step assumed a single watch call is authoritative.

**Suggested fix:** After `gh pr checks --watch` exits, re-query the full rollup
(`gh pr view --json headRefOid,statusCheckRollup`) and confirm every check is in
a terminal state (`SUCCESS`/`FAILURE`, none `PENDING`/`IN_PROGRESS`) before
declaring CI green; re-issue the watch if any check is still pending.
