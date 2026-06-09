---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** For each added `FOO=$(...)` capture, if a canonical name is
  referenced in later hunks, verify the `CANONICAL=$FOO` promotion appears
  before the block ends.
- **Why:** A capture refactored for same-block guarding without promoting its
  value leaves the canonical downstream name unset — silent failure on the
  inferred path; existing 2.7 only covers function-parameter additions.
- **Where:** Sweep 2.26 (Capture-variable promotion check),
  `grep -nE '^\+[A-Z_]+=\$\('`.
