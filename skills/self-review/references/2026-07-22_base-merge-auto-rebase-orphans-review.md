---
class: principle
---

**Rule:** Delete and re-anchor a pending self-review on ANY event that rewrites
the pushed HEAD — a self-initiated force-push OR a host-initiated auto-rebase
when the base branch merges and the child is retargeted. Before treating a
staged review as live, confirm its `commit_id` equals the current HEAD
(`gh pr view --json headRefOid`).

**Why:** A pending review's `commit_id` pins it to a HEAD SHA; a
base-merge-triggered auto-rebase rewrites every commit to new SHAs and silently
orphans the review and its inline comments, exactly like a force-push. The prior
clause named only self-initiated force-push, so the auto-rebase case did not
obviously apply.

**Where:** wk-self-review, "Updating an Existing Self-Review".
