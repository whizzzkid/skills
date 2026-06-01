---
class: principle
skill: wk-pr
date: 2026-06-01
severity: medium
---

- **Rule:** After detecting `$BEST_BASE` ≠ default, check whether the
  base is an open PR still in draft; if so, default auto mode to B
  (retarget to default, include both changesets), not A (stack).
- **Why:** Stacking on an unmerged draft parent produces two PRs the
  reviewer must sequence — usually a false split where both changesets
  should land together.
- **Where:** Step 1 → "Detect the true base branch" → new "Draft-base
  override" paragraph after the auto-mode default.
