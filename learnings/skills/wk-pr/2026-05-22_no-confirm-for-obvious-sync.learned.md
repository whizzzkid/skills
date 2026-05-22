---
skill: wk-pr
date: 2026-05-22
type: correction
severity: medium
---

Agent asked user for confirmation before syncing a stale PR description.

**What happened:** After identifying the PR body had drift (3 stale bullets), agent asked "Want me to update X?" User corrected: "don't ask me such basic question, if anything is adrift it needs to be fixed."

**Root cause:** Treating artifact sync as a decision requiring user approval, when it is an obviously-always-yes action. PR body sync on drift is prescribed by wk-commit and wk-pr.

**Suggested fix:** After any push or refactor, audit PR body, self-review, docs, and Jira — fix all drift in the same turn without asking. Only ask when the *content* of the sync is ambiguous, never for the *decision* to sync.
