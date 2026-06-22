---
class: principle
---

**Rule** — Feed the adversarial subagent the PR title/body purpose section. When the PR explicitly documents a change as intentional, test-only, or throwaway, treat that as stated context — do not classify documented-intentional design as a blocker. Keep the guard on production branches where the same pattern is unflagged.

**Why** — Without the PR's stated purpose, a subagent flags an intentional gate removal (e.g. a CI gate dropped to force a step to run for validation) as a security/data-loss blocker. The call is correct in isolation but wrong given documented intent, producing false blockers on throwaway test branches.

**Where** — Step 3 (Fresh Adversarial Subagent), intent-aware stance. The diff alone lacks design intent; the purpose section supplies it.
