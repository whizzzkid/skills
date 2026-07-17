---
class: principle
---

**Rule:** Lens findings on executable logic are hypotheses, not conclusions. When
the reviewed doc describes executable logic (matcher, grader, parser, state
machine, algorithm) — especially one naming a concrete existing implementation —
drive the real implementation (or a minimal faithful harness) with adversarial/edge
inputs and record actual PASS/FAIL before returning findings. Mark any finding you
could have tested but only argued as Unverified.

**Why:** Static lenses generate strong hypotheses but never execute anything, so
emergent interactions (two orthogonal knobs coupling) and exact break points stay
invisible; returning lens output as "the review" lets a downstream skill treat
un-run reasoning as validated.

**Where:** wk-arch-review — new "Empirical pass — execute logic-bearing specs"
block before Step 4; Lens C extended from *reading* the runtime to *executing* it.
