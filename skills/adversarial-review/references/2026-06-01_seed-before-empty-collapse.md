---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: high
---

- **Rule:** Flag any collection seeded/prepended with a non-empty value
  *before* an emptiness guard that collapses to a compact form —
  verify the guard decides on substantive content only, with decoration
  added after the gate.
- **Why:** The seed alone makes the guard evaluate false, so the
  "nothing to show" path renders the full template carrying only the
  seed and no findings — silently defeating the compact form.
- **Where:** Step 2 → new mechanical sweep 2.23 (Seed-before-empty-collapse).
