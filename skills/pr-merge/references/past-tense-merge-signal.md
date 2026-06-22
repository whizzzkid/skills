---
class: principle
---

**Rule** — A past-tense merge signal ("the PR is merged", "it's been merged", "PR landed", "update the ticket, it merged") triggers wk-pr-merge before any other action — just as binding as an imperative "merge this". Never transition the linked ticket inline via the Jira MCP. If the PR is already `MERGED`, skip the pre-merge checklist and resume at the ticket-transition step.

**Why** — The merge event is the skill's trigger condition regardless of tense. The skill owns ticket transition, follow-up collection, retro, and worktree cleanup; calling the Jira MCP inline does only the transition and silently skips the rest. Treating "update the ticket" as the whole task buries those steps.

**Where** — wk-pr-merge "When to Use". The trigger is the merge event, not the imperative phrasing.
