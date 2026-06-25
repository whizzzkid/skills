---
class: principle
---

**Rule:** When body headroom is single-digit bytes, the new rule's own full byte
size IS the reclaim quantity. Sum the new content's bytes, select reclaim targets
totaling ≥ that sum, and apply them in ONE pass before the first remeasure.

**Why:** Trimming a little then remeasuring (over → trim → over → trim) turns one
edit into a multi-cycle search loop. Each cycle is a full edit + hook-algorithm
measure round-trip. A re-violation of the existing "budget the reclaim before
drafting / measure once to confirm, not repeatedly to discover" rule — the failure
mode was reclaiming in dribs, not the measurement tool.

**Where:** Step 7.5 de-bloat byte-budget rule (sub-bullet under "Budget the
reclaim before drafting when headroom is tight").
