---
skill: wk-pr-merge
date: 2026-06-22
type: correction
severity: high
---

Invoke wk-pr-merge immediately when the user signals the PR is merged

**What happened:** User said "the PR is merged, update the ticket status." The agent manually called the Jira MCP tools directly instead of invoking `wk-pr-merge`. The skill covers Jira transition, follow-up collection, retro, and worktree cleanup — all were skipped.

**Root cause:** The agent treated "update the ticket" as the only task and executed it inline, not recognizing that the merge event is the trigger condition for `wk-pr-merge`. The skill's "When to Use" section includes "user says 'merge this', 'ship it'" but not "the PR was merged" as past-tense signal — however the merge event itself is the trigger, regardless of tense.

**Suggested fix:** Any user message indicating a PR has just merged ("the PR is merged", "it's been merged", "PR landed") must trigger `wk-pr-merge` before any other action. The skill handles Jira transition as one of its steps; invoking the MCP directly bypasses retro, follow-up collection, and worktree cleanup. Past-tense merge signals are just as binding as imperative ones.
