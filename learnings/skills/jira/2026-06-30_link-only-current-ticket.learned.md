---
skill: wk-jira
date: 2026-06-30
type: correction
severity: low
---

Link only the ticket being worked on in the PR description — do not add parent epics or related tickets.

**What happened:** The PR description's `## Meta` section included a `Related:` line linking the parent epic alongside the primary ticket. The user asked for it removed — only the directly-worked ticket belongs in the PR body.

**Root cause:** When a ticket has a parent epic, there is a temptation to provide navigation context by linking the epic. But the PR description is scoped to the work item, not the epic hierarchy; the epic link adds noise and is not actionable for reviewers.

**Suggested fix:** In `## Meta`, emit exactly one `Ticket:` line pointing to the ticket being worked on (derived from the branch name or commit message). Do not add `Related:`, `Epic:`, or parent-ticket lines unless the user explicitly requests them.
