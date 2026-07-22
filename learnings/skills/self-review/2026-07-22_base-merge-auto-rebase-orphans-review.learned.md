---
skill: wk-self-review
date: 2026-07-22
type: gap
severity: medium
---

A staged pending self-review is orphaned when the base branch merges and the host auto-rebases the child PR — not only on a self-initiated force-push.

**What happened:** A pending review was staged against a stacked PR. Its base branch (another open PR's head) then merged; the host auto-retargeted and rebased the child onto the new base, rewriting every commit to new SHAs. The pending review, pinned via `commit_id` to the old HEAD, was silently orphaned — its inline comments no longer resolved.

**Root cause:** The skill's "Updating an Existing Self-Review" clause names only self-initiated force-push as the trigger for delete + re-anchor. A base-merge-triggered auto-rebase is an equivalent history rewrite the agent does not initiate, so the clause did not obviously apply.

**Suggested fix:** Broaden the force-push clause to "any event that rewrites the pushed HEAD — including a host-initiated auto-rebase when the base branch merges." Add a pre-check: before treating a pending review as live, confirm its `commit_id` still equals the current PR HEAD (`gh pr view --json headRefOid`); on mismatch, `DELETE` the review and re-stage anchored to the new HEAD.
