---
class: principle
---

- **Rule:** After CI goes green, run every unchecked test-plan
  verification command before updating the PR description. Leave a box
  unchecked only when verification is genuinely impossible.
- **Why:** "I didn't happen to run this" is not a gate; deferring to the
  user to notice a runnable-but-unchecked box is a workflow failure.
- **Where:** Phase 6 Exit Conditions → "verify every test-plan checkbox"
  HARD RULE.
