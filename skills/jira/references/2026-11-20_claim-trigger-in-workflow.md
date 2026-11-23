---
class: principle
skill: wk-jira
date: 2026-11-20
---

# The claim trigger must live in the skill that loads first

- **Rule:** A ticket key in context makes `wk-workflow` Phase 1 invoke `wk-jira` for the claim before `wk-plan`, and
  live ticket status is re-checked at every PR create, ready, and merge. The existing `wk-jira` HARD RULE is
  escalated one rung (`Important`).
- **Why:** The key was in the session-opening prompt, yet the ticket sat in Backlog through PR creation and approval:
  the workflow fired first and `wk-jira` was never invoked. A rule that lives only in a skill which never loads
  cannot fire, so the trigger was added to the workflow skill, which always loads.
- **Where:** `skills/workflow/SKILL.md` → Phase 1; `skills/jira/SKILL.md` → Trigger rules (escalated label).
