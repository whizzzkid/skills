# Active-Sprint Assignment (subroutine)

Invoked after status transition in Stage 2 (In Progress) and Stage 4
(In Review). Failure mode: a ticket with no sprint lands in the
backlog — invisible on the sprint board, absent from velocity tracking.

## Steps

1. Find the active sprint on the ticket's project board:

   ```
   mcp__claude_ai_Jira_Confluence__searchJiraIssuesUsingJql(
     jql="project = <PROJECT> AND sprint in openSprints()")
   ```

   Read the sprint field from any returned issue → active sprint id.

2. Set it on the ticket via `editJiraIssue`. Sprint field id is custom per
   instance (commonly `customfield_10020`) → resolve from issue/field
   metadata rather than assuming the number, then write the value in the
   shape the field expects (often `[{ id: <sprintId> }]`).

3. Skip silently when no active sprint exists or field unavailable — not
   every board runs sprints.

4. **Verify the write landed.** After `editJiraIssue`, re-read the sprint field.
   An active sprint was found but the field is still null → do not report
   "sprint <name>"; surface the unset field so the ticket is not silently left
   in the backlog. Silent-skip covers only the no-active-sprint case, never a
   failed write masquerading as one.
