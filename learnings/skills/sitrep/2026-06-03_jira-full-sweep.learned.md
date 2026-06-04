---
skill: wk-sitrep
date: 2026-06-03
type: gap
severity: high
---

Jira agent must query all open assigned tickets, not just today's activity.

**What happened:** The evening sitrep Jira agent only fetched tickets "updated or commented on today," surfacing 1 ticket. A direct query of all open assigned tickets revealed 14 open tickets including a High-priority bug In Review, a merged-but-unclosed ticket, a Blocked ticket, and a ticket past due by over a year. These were all absent from the sitrep.

**Root cause:** The agent spec scoped Jira queries to "today's activity" only. This misses the ambient open-ticket backlog that is directly actionable but didn't receive an update today.

**Suggested fix:** In Stage 2 Agent 6, add a third JQL query alongside the today's-activity queries:

```
assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC
```

Return all results but surface in the sitrep only:
- Status = In Review / Ready for Review / Blocked / On Deck (actionable now)
- Tickets where the linked PR was merged but the ticket is still open (transition candidates)
- Any ticket with a due date in the past

Backlog tickets with no recent activity and no due date can be omitted from the daily checklist but should appear in a collapsed "Jira backlog" section so the user has a full picture once per day.
