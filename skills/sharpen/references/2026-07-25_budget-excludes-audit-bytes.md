---
class: principle
---

**Rule** — Budget the fold **plus an audit-cleanup allowance** (~25% of the fold, floor
~300 B) and size reclaim against that total. State the binding gate as *net non-positive
AND every ceiling clear*; treat the ≥1.2× reclaim ratio as the planning target it is.

**Why** — Step 7.5 sequences measurement before drafting, but Step 5 mandates resolving
contradictions and bundling cleanup into the same change, and those bytes are *discovered*
after the budget locks. The fold that introduces a contradiction is precisely the one whose
cleanup could not be foreseen, so the ordering **guarantees** the overrun rather than merely
permitting it. Without an allowance, a correctly-computed budget still breaks.

**Reporting rule** — A post-draft cleanup overrun that leaves net non-positive and the body
under ceiling is reported as arithmetic. It does not open a second reclaim hunt; that hunt
is what pressures an agent into trading away a correctness property for bytes.

**Hard stop** — Never reclaim by relocating a gate's enumerated pass/fail checks or a
verification checklist behind a pointer. The ceiling exists to protect load-bearing rules,
so it can never outrank them. Per-hook recovery rows are catalog, not gate — those move
freely.

**Where** — wk-sharpen Step 7.5, size-ceiling budget; full mechanics in `byte-budget.md`.
