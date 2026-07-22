---
class: principle
---

- **Rule**: After any force-push/rebase on a PR that already has a pending
  self-review, delete the stale review (`DELETE /pulls/{n}/reviews/{id}`) and
  re-stage a fresh pending review anchored to the new HEAD SHA. Gate the step on
  "was the branch force-pushed since the review was staged?".
- **Why**: A pending review's `commit_id` pins it to a specific HEAD; a
  force-push replaces that HEAD, so the anchor and every inline comment go stale
  (the comments endpoint returns empty) and GitHub does not migrate them — the
  review sits invisible.
- **Where**: wk-self-review "Updating an Existing Self-Review" flow.
