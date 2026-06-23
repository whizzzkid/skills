---
skill: wk-plan
date: 2026-06-23
type: gap
severity: medium
---

Jira lifecycle steps must appear as named plan items when a ticket is in scope.

**What happened:** The plan omitted Jira state transitions (In Progress, PR comment, In Review) as explicit numbered steps. They were handled as background side-effects by wk-jira, but this made them invisible in the plan and prone to being skipped or blocked without the user noticing.

**Root cause:** wk-plan treats Jira as an ambient concern handled by wk-jira triggers, rather than surfacing its steps in the plan body. When auto mode blocks a Jira write (external-system-write classifier), there is no plan step to retry against.

**Suggested fix:** When a Jira key is detected at plan time, add an explicit step group: "(Jira) claim ticket In Progress", "(Jira) post PR-opened comment", "(Jira) transition In Review on gh pr ready". Mark each `[AGENT-READY]` with the caveat "auto mode may block — if denied, re-invoke wk-jira or approve the permission in settings."
