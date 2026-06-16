---
class: principle
date: 2026-06-16
---

- **Rule:** On a gate-reorder diff, enumerate every call the reordered path
  used to make and now cannot; verify each `not_to receive` test covers all
  now-unreachable calls in the chain, not just the deepest.
- **Why:** A reorder changes which calls fire on failure paths even when
  return values are unchanged; the diff usually only touches the deepest
  assertion, leaving earlier-call assertions missing — and may expose a
  latent unstubbed-network hazard.
- **Where:** Sweep 2.37 (gate-reorder negative-assertion completeness).
