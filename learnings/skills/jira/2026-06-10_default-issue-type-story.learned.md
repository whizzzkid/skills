---
skill: wk-jira
date: 2026-06-10
type: correction
severity: low
---

Default issue type to Story when creating tickets, not Task.

**What happened:** Agent defaulted to `issueTypeName: "Task"` when creating a new Jira issue. User corrected to Story.

**Root cause:** The skill has no stated default issue type; agent fell back to "Task" as a generic choice.

**Suggested fix:** In the Manual ticket operations section and any create examples, specify that the default `issueTypeName` should be `"Story"` unless the context clearly calls for a different type (Bug, Task, Epic).
