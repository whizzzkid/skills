---
skill: wk-gh
date: 2026-07-22
type: gap
severity: medium
---

`statusCheckRollup.headRefOid` can lag the actual pushed remote tip, so a single rollup read reports a stale build state for the prior commit.

**What happened:** After pushing a fix, `gh pr view --json statusCheckRollup` (and a `gh pr checks --watch` exit) repeatedly reported the OLD head with a failing check, even though the remote tip had already advanced and the CI provider showed the new commit passing. The rollup's `headRefOid` itself trailed the push by webhook-propagation delay.

**Root cause:** The skill warns that `--watch` can exit on a partial-resolve of the current commit's checks, but not that the rollup's `headRefOid` can point at a superseded commit entirely — a different staleness axis.

**Suggested fix:** Before trusting rollup state, assert `.headRefOid` equals the pushed tip (`git ls-remote origin <branch>`). If they differ, the rollup is stale for the wrong commit — re-query until it catches up, or fall back to the CI provider's build-by-branch query (which reflects the true current commit) as ground truth.
