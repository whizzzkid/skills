---
class: principle
date: 2026-05-22
source: learnings/skills/wk-pr/2026-05-22_no-confirm-for-obvious-sync.md
---

- **Rule:** Syncing a stale artifact (PR description, self-review thread, Jira ticket, project doc) is an obviously-always-yes fix; never ask the user before syncing drift. Ask only when the *content* of the sync is ambiguous, never for the *decision* to sync.
- **Why:** Asking "want me to update the PR body?" is friction without value — drift is prescribed for fixing by wk-commit / wk-pr / wk-jira; the agent is the one supposed to know it.
- **Where:** Step 3 (Update PR description) HARD RULE — no-ask on drift sync.
