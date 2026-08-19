---
class: principle
---

**Rule** — Route to `wk-design-review` when a diff touches CSS, design tokens, colors, borders, or visual styles; catch design-system violations at the pre-commit workstyle pass, not only at adversarial review.

**Why** — Decorative use of semantic status palette (a Phase-2 design-system violation) shipped past workstyle into the adversarial-review gate because no routing rule dispatched design checks earlier.

**Where** — `SKILL.md` → Step 1 → Universal rule sets (by change type) table.
