---
class: principle
skill: wk-plan
date: 2026-11-20
---

# Probe a test environment's preconditions before offering it

- **Rule:** Before offering any test-environment option, run one read-only probe per precondition the test needs
  (for example recent PR reviews by author type, or the branch protection / ruleset API). Offer only options the
  probes confirm; label anything unverifiable "unverified" in its description.
- **Why:** An option was drafted from assumption ("the review bot approves it") and the user picked it. A later probe
  showed the repo had no review bot and no branch protection, so the chosen target could not produce the scenario the
  test existed to exercise.
- **Where:** `SKILL.md` → Step 0 (Grill).
