---
class: principle
skill: wk-commit
date: 2026-11-20
---

# Never end a turn between commit and push

- **Rule:** Never end a turn between a commit and its push, or between an authorized first push and `wk-pr`. A summary
  that lists push or PR creation as "next steps" is a stall; run them in the same turn.
- **Why:** Under an authorized PR lifecycle the agent committed, wrote a summary naming push, PR, and review as next
  steps, and stopped. The commit summary read as a natural turn boundary, so the push mandate was reported instead of
  executed, and the user had to ask what the agent was waiting for.
- **Where:** `SKILL.md` → Pushing, sub-bullet of the push-after-every-commit rule.
- **Escalation:** re-violation of "the push is the tail of the commit sequence" (installed 2026-10-09, before the
  report). Escalated one rung: baseline prose → `**Important:**` sub-bullet naming the turn-boundary stall.
