---
skill: wk-pr
date: 2026-05-04
type: gap
severity: medium
---

PR title must append `[JIRA-TICKET]` when the task originates from a Jira ticket.

**What happened:** PR #NNN was created with title `feat({scope}): ✨ configurable sandbox model via $AGENT_MODEL` — no Jira ticket number appended, even though the task explicitly referenced BOARD-NUM.

**Root cause:** `wk-pr` Step 2 has no instruction to extract the Jira ticket number from the task description or branch name and append it to the PR title.

**Suggested fix:** In Step 2 (Create Draft PR), before composing the title, check the branch name and the user's task description for a Jira ticket pattern (`[A-Z]+-\d+`). If found, append `[TICKET]` to the end of the PR title. Example: `feat(scope): ✨ description [BOARD-NUM]`.
