---
date: 2026-05-13
slug: jira-ticket-pre-flight
---

- **Rule:** Check for a Jira ticket before any exploration in Phase 1; invoke `wk-jira` Stage 0+1+2 when a ticket exists.
- **Why:** Ticket acceptance criteria and linked specs are plan inputs; surfacing them after exploration wastes the turn and risks contradicting the plan.
- **Where:** `Phase 1 → Jira ticket pre-flight` in `wk-workflow` SKILL.md (placed before "Investigate user-provided artifacts first").
