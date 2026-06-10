---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** When a replacement/scrub map has tokens where one is a substring of
  another, order replacements longest-first (sort by descending token length).
- **Why:** A short replacement applied first corrupts every longer token that
  contains it (e.g. `foo`→`x` mangles `foo-bar` before the `foo-bar` rule runs).
- **Where:** Step 5 mechanical overfit scan — "Replacement-order rule".
