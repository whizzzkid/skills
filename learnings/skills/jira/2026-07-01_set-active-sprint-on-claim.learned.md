---
skill: wk-jira
date: 2026-07-01
type: gap
severity: low
---

A ticket created/claimed and worked within an active sprint must have its sprint field set, not left null.

**What happened:** A bug ticket was created, transitioned Backlog → In Progress → Done, and merged all within one active sprint, but its sprint field (`customfield_10020`) was left null the entire time. The user had to prompt for it after the ticket was already Done.

**Root cause:** The Jira lifecycle steps (claim → In Progress, PR-opened comment, → In Review, → Done) cover status transitions and comments only. None prompts setting the active sprint when claiming a ticket, so a ticket worked mid-sprint silently lands in no sprint.

**Suggested fix:** In the "claim ticket → In Progress" lifecycle step, add: detect the board's active sprint (JQL `project = <KEY> AND sprint IN openSprints()`, read `customfield_10020` from any result) and set it on the ticket via `editJiraIssue` if the sprint field is null. A ticket actively worked belongs in the current sprint; leaving it null skews sprint reporting.
