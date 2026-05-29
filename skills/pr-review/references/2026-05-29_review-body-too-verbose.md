---
class: principle
date: 2026-05-29
severity: medium
---

- **Rule:** The review body must not restate information visible in the diff —
  test counts, field/variable names, regex identifiers, list contents. Limit it
  to the verdict plus one non-obvious insight.
- **Why:** The author can read the diff; narrating it back adds no signal and
  dilutes the verdict.
- **Where:** Phase 6 "Compose the review body" → Review body antipatterns
  (Diff narration bullet).
