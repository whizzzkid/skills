---
class: principle
skill: wk-jira
date: 2026-11-20
---

# Every ticket create ends with a hand-off prompt

- **Rule:** After every ticket create, present a fenced hand-off prompt in the same response: the ticket key, the
  problem with the facts already verified, the acceptance criteria, the starting files, the constraints and gates
  (env/container rules, required checks), what is out of scope, and an opening instruction to start the dev workflow
  skill.
- **Why:** A follow-up ticket was created and reported only by key and summary, so the user had to ask separately for
  a prompt another agent could pick it up with. The verified context exists only in the creating session.
- **Where:** `SKILL.md` → Manual ticket operations.
