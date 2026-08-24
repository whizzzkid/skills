---
skill: wk-workflow
date: 2026-08-24
type: correction
severity: medium
verified-against-source: n/a
---

Created Jira stories without assigning them to the current sprint — tickets landed in the backlog.

**What happened:** When creating 5 Jira stories via the MCP connector's `createJiraIssue`, the `additional_fields` included `parent` (epic link) and `priority` but omitted the `sprint` field. All tickets landed in the backlog instead of the active sprint, requiring manual correction by the user.

**Root cause:** The Jira story creation step in the workflow has no instruction to query the active sprint and include it in `additional_fields`. The sprint field is not set by default when creating issues — it must be explicitly provided. The agent assumed epic linkage was sufficient for board placement.

**Suggested fix:** Add to the Jira lifecycle steps in wk-plan/wk-workflow: "Before creating a Jira issue, query the project's active sprint (`getVisibleJiraProjects` or the board's sprint endpoint) and include `"sprint": {"id": <active_sprint_id>}` in `additional_fields`. Never create a story without a sprint assignment — backlog placement requires manual correction."
