---
skill: wk-pr-merge
date: 2026-07-20
type: gap
severity: medium
---

Auto Mode classifier can deny `gh pr merge` even when the skill "approves" the merge tool.

**What happened:** Step 6 ran the squash-merge command; it was denied by the Auto
Mode classifier ("Blocked by classifier"), not by a skill/settings allowlist. The
user asked why it blocked despite the tool being approved in the skill. The merge
had to be completed manually by the user outside the agent.

**Root cause:** The skill assumes the merge command will succeed or fail only on
branch-protection / merge-method grounds. It does not account for a separate
permission layer (the Auto Mode classifier) that can block irreversible actions
like `gh pr merge` regardless of the invoking skill's own tool allowlist. Skill
allowlists and the classifier are independent gates.

**Suggested fix:** In Step 6, note that a classifier/permission-layer denial is a
distinct failure mode from a branch-protection failure: on such a denial, do not
retry verbatim — explain the two-layer model (skill allowlist vs. host
classifier) and that an explicit `Bash(gh pr merge:*)` settings rule (or a manual
user merge) is required. Treat a subsequent manual/past-tense merge as the Step 1
already-`MERGED` path and resume at Step 7.
