---
class: principle
---

**Rule:** When reclaiming bytes under a size ceiling, budget reclaim targets whose
combined size exceeds the overage *with margin* (≥1.2×), not merely strictly. A
strict-exceed plan undershoots in practice and reopens the measure-trim loop. On a
still-over measure, re-plan with one decisive scaffolding/content cut — never another
prose nibble.

**Why:** A fold summed reclaim candidates to roughly the overage, landed a few bytes
over, then trimmed three more times before a decisive scaffolding cut cleared it —
exactly the forbidden measure-trim thrash. Root cause: approximate (not margin-backed)
budgeting plus weakest-cut-first ordering.

**Where:** wk-sharpen Step 7.5 de-bloat pass, reclaim-budget bullet.
