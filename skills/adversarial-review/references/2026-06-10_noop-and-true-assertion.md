---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
severity: high
---

- **Rule:** Grep changed test files for `&& true` on a line that also
  contains `||`; treat each hit as a no-op assertion blocker.
- **Why:** Bash `||`/`&&` are equal-precedence left-associative, so a
  trailing `&& true` forces the whole compound to exit 0 — the test can
  never fail.
- **Where:** Sweep 2.19 (Tautological test assertion scan). Fix:
  `... || (echo "diagnostic" && false)` so `false` propagates as exit
  status.
