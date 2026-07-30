---
class: principle
---

**Rule:** Clearance survives tree-identical rewrites and commits that map only
to recorded findings, with no unmatched scope, refactor, or logic. Validate the
recorded findings only; unmatched work receives one delta-scoped review.

**Why:** Re-running the gate against a delta that is purely the mechanical application of the verdict's own findings re-reviews changes the verdict already implied — wasted work with no new risk surface. The carve-out is narrow on purpose: a single logic/refactor/scope commit in the delta voids it.

**Where:** [`wk-pr`](../README.md) Hard Rule 2 and Step 5 completion gate.
