---
skill: wk-self-review
date: 2026-07-22
type: gap
severity: medium
---

A pending self-review is orphaned by a force-push; delete and re-post it.

**What happened:** After a rebase + force-push rewrote a PR branch, the
previously-staged PENDING self-review stayed anchored to the old (now
force-pushed-away) commit SHA and its inline comments no longer resolved to any
diff line (the comments endpoint returned empty). The stale review sat invisible.

**Root cause:** A pending review's `commit_id` pins it to a specific HEAD. A
force-push replaces that HEAD, so the anchor and every inline comment go stale;
GitHub does not migrate them to the new head.

**Suggested fix:** After any force-push/rebase on a PR that already has a pending
self-review, delete the stale review (`DELETE /pulls/{n}/reviews/{id}`) and
re-stage a fresh pending review anchored to the new HEAD SHA. Add this as an
explicit step to the "Updating an Existing Self-Review" flow, gated on
"was the branch force-pushed since the review was staged?".
