---
class: principle
date: 2026-05-19
source: learnings/skills/adversarial-review/2026-05-19_tautological-sort-test.md
---

- **Rule:** Reject test assertions where both sides of an equality
  derive from the same source variable(s).
- **Why:** Such assertions pass regardless of production behavior —
  inverting, deleting, or no-op'ing the implementation still passes.
- **Where:** Step 2 mechanical sweeps, sub-section 2.19 — Tautological
  test assertion scan.
