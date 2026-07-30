---
class: principle
skill: wk-pr
date: 2026-07-28
severity: medium
---

# Re-review only unmatched new work

- **Rule:** Review once at the completion gate. Tree-identical rewrites preserve
  clearance; finding-response commits validate only recorded findings. Review
  again only for unmatched scope, refactor, or logic.
- **Why:** SHA movement over-fired on the review's own fixes and made review cost
  scale with fix rounds instead of unreviewed work.
- **Verification:** The strict SHA rule predated the report. A later ownership
  fold reduced dispatch sites but still re-reviewed every non-empty delta.
- **Escalation:** Store blocked finding evidence and add a targeted-validation
  branch; this replaces repeated full-review prose with a distinct mechanism.
- **Where:** [`wk-adversarial-review`](../../adversarial-review/README.md) owns
  lineage; [`wk-pr`](../README.md) owns the completion gate.
- **Budgets:** adversarial review 24,552 → 24,016; PR 24,395 → 24,353;
  workflow 24,449 → 24,050. Every touched body is net negative.
