---
class: principle
---

**Rule:** A seed/sync/fetch step that gates a baseline read must gate the downstream write-back on the helper's actual return value, not a re-check of the helper's trigger precondition. Treat a command exiting 0 with empty stdout as failure.

**Why:** When the seed and write-back guard on independent conditions (or the caller re-checks `X.success?` while the helper also ran on `X.success?`), a failed intermediate step leaves the write-back running from a stale baseline — the clobber the seed was added to prevent. `git show` of a missing blob exits 0 with empty output. Consolidates the seed-gate-symmetry and return-value-gate-divergence learnings.

**Where:** Sweep 2.45.
