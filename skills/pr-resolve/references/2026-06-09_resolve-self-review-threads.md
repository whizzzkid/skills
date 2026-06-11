---
class: principle
date: 2026-06-09
skill: wk-pr-resolve
Supersedes: refines Hard Rules 3 & 8 (never resolve self-review threads) with a merge-readiness resolution carve-out
---

- **Rule:** At end of cycle, resolve the author's own **submitted**
  (non-pending) self-review threads that are `isResolved == false` — query
  `reviewThreads`, `resolveReviewThread` each. Resolution only: never
  triage, reply, or suggest fixes.
- **Why:** Branch protection counts every unresolved thread regardless of
  authorship, so unresolved self-review notes block merge.
- **Where:** Hard Rule 3 + Hard Rule 8 carve-out + Step 7 Resolution rule
  merge-readiness exception. Pending (draft) self-reviews still never
  resolved.
