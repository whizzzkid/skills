---
class: principle
---

# Re-map verifier-assigned severity before the approve gate

- **Rule:** Put Phase 4's severity definitions verbatim in every verifier prompt. Before the approve gate, re-map each
  verifier-assigned `concern` against them; anything that is not correctness, security, or data loss becomes a
  `suggestion`.
- **Why:** A parallel verify pass (one refuting agent per finding) confirmed most findings but labelled a metrics-skew
  issue `concern`, which would have held approval on a non-critical item. The verifier prompts asked for a severity
  draft without restating what `concern` is reserved for.
- **Where:** [`wk-pr-review`](../README.md) → Phase 3, after bot-finding routing.
