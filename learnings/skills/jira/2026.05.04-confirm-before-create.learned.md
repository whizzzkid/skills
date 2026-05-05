---
skill: wk-jira
type: correction
severity: high
suggested_fix: Always present proposed Jira items to the user for approval before calling createJiraIssue or any other write operation. Never infer intent from ambiguous input.
---

## Incident

User asked to "create user stories from my meeting with Sweta and Alpha today." Multiple meetings existed — a full team standup and a private 3-person meeting. Agent picked the standup (wrong meeting) and created 5 stories without confirming either the source meeting or the proposed stories.

## Lesson

**Always confirm with the user before creating, editing, or deleting any Jira item.**

When a request involves multiple candidate meetings (or any ambiguity about source, scope, or target), present the options and your interpretation *before* taking action. Creating Jira issues is irreversible in practice (no delete API; only "Won't Do" transition available).

## Rule to add to wk-jira

Before any `createJiraIssue` call:
1. If the source (meeting, doc, conversation) is ambiguous, list the candidates and ask which one.
2. Present the proposed stories/tasks as a bulleted list for user approval.
3. Only proceed after explicit confirmation.
