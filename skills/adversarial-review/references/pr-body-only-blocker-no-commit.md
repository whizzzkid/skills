---
class: principle
---

**Rule:** When the only blocker is PR-body drift (sweep 2.8/2.10 body check, no code change), fix it via `gh pr edit` with no new commit and re-verify against the same HEAD SHA. The `.cleared-{HEAD_SHA}.json` record stays valid.

**Why:** PR body is GitHub API state, not a committed file. Committing a no-op to satisfy the fix loop pollutes history; the code is unchanged so the clearance record holds.

**Where:** Step 7 fix loop.
