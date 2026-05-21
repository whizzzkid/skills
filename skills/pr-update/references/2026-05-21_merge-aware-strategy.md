---
name: merge-aware-strategy
description: Branches that already contain a merge from the base must not be measured by raw $AHEAD.
class: principle
---

- **Rule:** Before applying the strategy heuristic, check whether
  HEAD contains a merge commit from the base. If so, recompute
  `$AHEAD` against the most recent base-merge. When the recomputed
  count is small, run `git merge "$BASE_REF"` directly instead of
  rebase or patch-replay.
- **Why:** Raw `$AHEAD` on a merge-style branch overstates the
  integration work — most of those commits were already merged in.
  Patch-replay on a merge-style branch squashes already-reviewed
  commits and destroys the merge topology reviewers rely on.
- **Where:** Stage 1 ("Merge-aware `$AHEAD` recomputation" block)
  and Stage 2 strategy table (new top row for merge-style branches).
