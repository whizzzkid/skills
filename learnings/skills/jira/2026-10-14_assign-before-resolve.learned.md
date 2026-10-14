---
skill: wk-jira
date: 2026-10-14
type: correction
severity: medium
verified-against-source: n/a
---

Terminal transitions outside the dev lifecycle skipped the assignee check, leaving child tickets unassigned.

**What happened:** While closing a security parent ticket and its auto-generated child findings as already-mitigated,
the agent commented and resolved every ticket but never checked assignees. The parent was assigned; the children were
not. The user had to ask before they got assigned.

**Root cause:** The assignment step exists only in Stage 2 (start work). Manual or terminal resolutions (Stage 5,
confirm-first manual ops, Child-completion gate) don't re-check the assignee, so tickets resolved without a claim
stay unowned.

**Suggested fix:** Before any terminal transition (Resolved/Done/Won't Fix), including children found via
`parent = KEY`, fetch the assignee and assign unset tickets to the user (never reassign someone else's). Report the
assignee state with the transition result.
