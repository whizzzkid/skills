---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: medium
---

- **Rule:** Treat a rename — even a behavior-preserving local-variable
  rename — as a removed-term change; run the variant grep across source,
  `docs/`, and test files (function names, comments, error-label /
  message strings), not just prose.
- **Why:** A "trivial local rename" is the change an author assumes is
  self-contained, so the cross-doc sweep is most valuable precisely when
  the diff looks too small to need it — stale spec word-choice tables
  and test labels otherwise survive.
- **Where:** Step 2 → sweep 2.8 → "Synonym + casing sweep for removed
  terms" (new rename bullet).
