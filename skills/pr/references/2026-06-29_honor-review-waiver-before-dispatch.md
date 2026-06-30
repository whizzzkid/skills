---
class: principle
---

**Rule:** When the user's current-session instruction waives the adversarial
review ("no review needed"), suppress the `wk-adversarial-review` Skill call
before dispatching it — do not invoke it and rely on the user denying the
resulting permission prompt to enforce their own instruction.

**Why:** Per using-superpowers, user instructions override skill hard rules. An
upfront waiver is an immediate decision, not context to note. Dispatching anyway
triggers a permission prompt the user must deny — friction that re-litigates a
decision they already made. (`wk-gh` routing + footer per Rule 0 still apply.)

**Where:** `## Step 2`, the adversarial-review gate — check the waiver before the
Invoke line, skip to `gh pr create` when waived.
