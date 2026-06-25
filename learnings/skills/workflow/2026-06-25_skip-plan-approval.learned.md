---
skill: wk-workflow
date: 2026-06-25
type: correction
severity: high
---

Invoked wk-plan but executed without waiting for plan approval.

**What happened:** After loading wk-workflow and wk-plan for a small config-file task, the agent skipped presenting a plan for user approval and jumped directly to implementation (creating a file, committing, pushing). The user had to point this out.

**Root cause:** Small-task rationalization — the change was 2 lines and the path seemed obvious, so the plan-and-wait gate was bypassed. wk-plan's HARD RULE ("Do not execute any step until the user approves the plan") was loaded but not obeyed.

**Suggested fix:** Treat wk-plan's approval gate as a hard prerequisite for the first Edit/Write/Bash write-action, regardless of diff size. "Small" is exactly the rationalization the rule forbids. Even a 2-line config change must go through present-plan → wait-for-approval → execute.
