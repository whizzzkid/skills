---
class: principle
skill: wk-pr-merge
date: 2026-05-29
---

# Count all unresolved threads — branch protection ignores "self-review"

- **Rule:** In Step 4, count every unresolved non-outdated review thread
  regardless of author; never exclude self-review threads from the merge gate.
- **Why:** GitHub branch protection has no concept of "self-review" — any
  unresolved thread blocks the merge. Excluding self-authored threads passes
  the skill's own gate, then GitHub rejects with `base branch policy prohibits
  the merge`.
- **Where:** Step 4 — HARD RULE "count ALL unresolved non-outdated threads";
  reviewer/bot threads route to wk-pr-resolve, self-review threads get resolved
  as a confirmed pre-merge cleanup via `resolveReviewThread`.
- **Note:** Corrects a prior same-session edit that mirrored wk-pr-resolve's
  triage-exclusion rule into the merge gate.
