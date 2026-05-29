---
skill: wk-pr-merge
date: 2026-05-29
type: gap
severity: high
---

Always verify PR actually merged after `gh pr merge --auto`; if not, diagnose and surface the blocker.

**What happened:** `gh pr merge --auto` queued successfully and the skill declared "Merge complete ✓", but the PR remained open because unresolved review threads blocked the merge queue. The user had to point this out.

**Root cause:** `wk-pr-merge` Step 6 checked `gh pr view --json state` immediately after the merge command, which returned `OPEN` (auto-merge queued, not yet merged). The skill logged the SHA as null and state as OPEN but still declared success, conflating "auto-merge queued" with "merged".

**Suggested fix:** After `gh pr merge --auto`, poll `gh pr view --json state,autoMergeRequest` until state is `MERGED` or a timeout (~60s) elapses. On timeout, re-fetch unresolved threads and any branch protection failures, then stop and report:
> "Auto-merge queued but PR has not merged after {N}s. Likely blockers: {list unresolved threads / failed checks}."
Never declare "Merge complete" until `state == "MERGED"`.
