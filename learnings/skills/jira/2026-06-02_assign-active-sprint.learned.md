---
skill: wk-jira
date: 2026-06-02
type: gap
severity: medium
---

Always assign the active sprint when transitioning a ticket to a working state (In Progress, In Review).

**What happened:** When creating a new ticket and transitioning it to In Progress or In Review, the skill did not fetch or set the active sprint field. The ticket landed in the backlog with no sprint, making it invisible in the team's sprint board and missing from velocity tracking.

**Root cause:** Stage 2 (start work) and Stage 4 (In Review) of the skill have no step to look up the active sprint and set `customfield_10020` (the standard Jira sprint field). The skill transitions status and assigns the user but omits sprint assignment.

**Suggested fix:** In Stage 2 (start work) and Stage 4 (PR ready → In Review), after the status transition, query for the active sprint on the project board using JQL (`project = {PROJECT} AND sprint in openSprints()`) and call `editJiraIssue` with `customfield_10020: [{id: <sprint_id>}]` to assign the ticket to the active sprint. Skip silently if no active sprint is found or the field is unavailable.
