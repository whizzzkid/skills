---
skill: wk-sharpen
date: 2026-06-25
type: correction
severity: medium
---

At near-zero headroom, reclaim the full new-rule cost up front in one batch, not via trim-measure cycles.

**What happened:** A target SKILL.md had ~12 bytes body headroom. The new rule (~280 B) was drafted first, then bytes were reclaimed reactively — five separate trim-then-remeasure cycles (over by 134, 77, 58, 9, finally +2 under) before clearing the ceiling. Each cycle was a full edit + hook-algorithm measure round-trip.

**Root cause:** The existing "Budget the reclaim before drafting" rule was followed in spirit (reclaim targets identified) but the *quantity* was under-estimated: I trimmed a little, measured, trimmed again. With single-digit-byte headroom the new rule's full size is the reclaim target — that total must be planned and applied in one pass, not discovered incrementally.

**Suggested fix:** Strengthen Step 7.5's budget rule: when headroom is under the drafted edit's own size, sum the new rule's byte cost first, then select reclaim targets totaling ≥ that sum *before* the first remeasure. Treat measure as a single confirmation, not a search loop. (Reinforces the just-folded "measure once to confirm, not repeatedly to discover" — the failure mode is reclaiming in dribs, not the measurement tool.)
