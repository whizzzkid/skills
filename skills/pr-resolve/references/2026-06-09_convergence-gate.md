---
class: principle
date: 2026-06-09
severity: medium
---

- **Rule:** Beyond the per-pair re-fire counter, add a convergence gate: if bot
  total active findings stop falling (count[N] >= count[N-1] two rounds) or a
  new finding reverses an accepted fix, present merge-vs-continue instead of
  another fix cycle.
- **Why:** Each fix round generates new reviewable surface; rising totals +
  accepted-fix reversals signal the review has exhausted real findings.
- **Where:** Step 9.5 thrash section — "Convergence gate" block.
