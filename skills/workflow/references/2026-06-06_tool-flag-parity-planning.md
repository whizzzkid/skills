---
class: principle
---

- **Rule:** When the plan swaps one tool for another in the same role,
  probe whether the replacement needs flags to match the prior tool's
  behavior, and name each gap-closing flag in the plan.
- **Why:** A replacement's defaults can diverge (especially CWD-sensitive
  or module-aware tools) between local and CI; without a planning probe the
  divergence surfaces only at adversarial review.
- **Where:** Phase 1 → "Tool-swap flag-parity probe" (before Plan Presentation).
