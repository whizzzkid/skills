---
class: principle
---

- **Rule:** The Jira agent queries all open assigned tickets (`assignee = currentUser() AND statusCategory != Done`), not just today's activity; surface actionable statuses, past-due, and merged-PR transition candidates; collapse the rest into a backlog section.
- **Why:** Scoping to today's activity hides the ambient actionable backlog — In Review bugs, blocked tickets, long-overdue items never surface.
- **Where:** start Stage 2 Agent 5 + end Stage 2 Agent 6 ("full open-ticket sweep").
