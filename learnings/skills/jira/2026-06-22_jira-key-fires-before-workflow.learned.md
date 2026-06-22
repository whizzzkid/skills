---
skill: wk-jira
date: 2026-06-22
type: correction
severity: high
---

wk-jira must fire on Jira key/URL in opening prompt, before wk-workflow Phase 1

**What happened:** A Jira URL was present in the user's first message. The agent invoked wk-workflow immediately instead of wk-jira first. Stage 0+1+2 (surface + claim) were skipped entirely — ticket was never moved to In Progress, not assigned, and no sprint was set at session start. The transition to In Review only happened after the PR was created, when the user explicitly asked why the ticket hadn't moved.

**Root cause:** wk-workflow's trigger ("any development task") fired first and dominated the turn. The wk-jira trigger rule ("Jira key in prompt → stages 0,1,6") was not applied before wk-workflow Phase 1 planning began. The skill's trigger table says to fire on key detection, but there is no explicit ordering instruction that puts wk-jira ahead of wk-workflow.

**Suggested fix:** Add an explicit ordering rule to wk-jira: when a Jira key or URL appears in the session-opening prompt, wk-jira Stage 0+1+2 must run *before* wk-workflow Phase 1. The development claim (assign + In Progress + sprint + comment) is a precondition for the work session, not a side-effect of it. wk-workflow Phase 1 should be gated on wk-jira completing its claim for the detected ticket.
