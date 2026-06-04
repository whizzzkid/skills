---
skill: wk-sitrep
date: 2026-06-04
type: gap
severity: high
---

Auto-transition Jira tickets to Done when the linked PR is confirmed merged — don't surface them as user TODOs.

**What happened:** During Stage 2 (Jira agent), a ticket was found in "In Review" status whose linked PR had been merged 2 days prior. The skill surfaced this as a `[ ]` checkbox for the user to action rather than transitioning it automatically.

**Root cause:** The skill spec has no step that cross-references PR merge state against Jira ticket status and performs the transition. The Jira agent returns ticket data; the orchestrator compiles it into checkboxes; neither step closes the loop.

**Suggested fix:** Add an auto-transition step to `start`, after the parallel agents return and before writing live.md:

1. For every Jira ticket returned by Agent 5 where `status != Done/Won't Do` and a linked PR URL is present, check the PR's merge status via the GitHub agent (or `gh pr view --json merged`).
2. If the PR is merged and the ticket status is `In Review` or `Ready for Review`, call `transitionJiraIssue` to move it to `Done` (transition id varies by project — fetch available transitions first).
3. Add a read-only note to live.md under a `## 🤖 Auto-Actions` section (or inline annotation on the checked item): `✅ auto-transitioned to Done by agent`.
4. Do NOT add these as `[ ]` checkboxes — they are already resolved. Surface them as `[x]` with the auto-action annotation so the user can see what was done.

Detection heuristic: ticket status is `In Review` or `Ready for Review` AND a linked PR with `state: closed, merged: true` exists AND the merge date is within the last 14 days.
