---
skill: wk-jira
date: 2026-05-15
type: gap
severity: medium
---

Description quality check silently skipped when trigger is Stage 4 (PR ready → In Review).

**What happened:** The skill was invoked via a Jira URL mention at the point of marking a PR ready for review. Stage 4 ran (ticket was already In Review, no-op), but the description quality check was never executed. The ticket had an empty description. The user had to explicitly ask whether the description had been filled in.

**Root cause:** The description quality check lives only in Stage 2 (start of work). Stages 4, 5, and 6 are scoped to status transitions or read-only surface and do not run the quality check. When a session starts mid-branch (after the initial commit but before a PR is ready), Stage 2 never fires and the check is permanently skipped.

**Suggested fix:** Run the description quality check at Stage 4 as well — not just Stage 2. At PR-ready time the description is still writable, the PR context is available to pre-fill fields, and it is the last natural checkpoint before reviewers see the ticket. Add to Stage 4: "After transitioning to In Review, fetch the ticket description and apply the same thinness check as Stage 2. Propose the context block if thin."
