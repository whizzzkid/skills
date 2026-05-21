---
name: merge-aware-pre-check
description: Pre-check before delegating base integration — plain `git merge` may be the right call.
class: principle
---

- **Rule:** Before delegating to `wk-pr-update` in Step 2, check
  whether HEAD already contains a merge from the base AND `$BEHIND`
  is small. If both true, run `git merge "$BASE_REF"` directly and
  skip delegation.
- **Why:** Unconditional delegation routes through patch-replay
  strategy selection, which would squash already-reviewed commits
  on a merge-style branch. The delegating skill cannot reason about
  merge topology from the size heuristic alone.
- **Where:** Step 2, "Integrate the base branch via `wk-pr-update`"
  block, leading merge-aware pre-check.
