---
class: principle
---

**Rule:** When a previously-void helper becomes fallible, its callers must gate downstream actions on the helper's return value — not on a re-check of the precondition that originally triggered the helper.

**Why:** The two conditions look equivalent until the intermediate step fails silently (fetch succeeds, seed fails) — then the gate stays open on a stale baseline. Folded together with seed-write-back gate symmetry.

**Where:** Sweep 2.45 (see [[seed-write-back-gate-symmetry]]).
