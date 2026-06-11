---
class: principle
date: 2026-06-10
skill: wk-pr-resolve
---

- **Rule:** Set up the adversarial-review gate by reading the diff
  (`git diff "$BASE...HEAD"`) — never run `git status` as a
  context-gathering step there.
- **Why:** Working-tree state was resolved at commit time; `git status` at
  review time reads as aimless exploration and adds nothing the diff lacks.
- **Where:** Step 8 Adversarial-review gate.
