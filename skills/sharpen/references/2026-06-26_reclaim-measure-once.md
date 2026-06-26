---
class: principle
---

**Rule** — At single-digit/near-ceiling headroom, measure the body exactly once: sum the new
rule's bytes, pick reclaim targets totaling ≥ that sum, apply in ONE pass, then measure. A
second measure-and-trim cycle is the re-violation signal — stop and re-plan the reclaim instead
of tweaking incrementally.

**Why** — At 12 B headroom, an agent ran ~5 trim-then-remeasure cycles. The existing
"trim-then-remeasure turns one edit into a search loop" rule was stated but did not steer
execution; each cheap measurement pulls toward incremental tweaking. Re-violation → escalated
one notch (baseline → `**Important:**`) and added an explicit violation-signal hard stop.

**Where** — Step 7.5, "Budget the reclaim before drafting" → "Important — measure exactly once"
sub-bullet.
