---
skill: wk-pr-review
date: 2026-07-28
type: correction
severity: high
verified-against-source: yes
---

GraphQL can append a new top-level comment to an existing pending review without
deleting or recreating the review.

**What happened:** A pending review already contained a user-authored draft
comment. The REST standalone-comment endpoint was unsuitable, but
`addPullRequestReviewComment` succeeded when given the pending review's explicit
`pullRequestReviewId`, the file path, and the unified-diff position. Both comments
remained pending and the original comment was unchanged.

**Root cause:** Existing guidance generalized the REST 422 behavior to all GitHub
surfaces. The GraphQL mutation has a dedicated `pullRequestReviewId` input that
targets the existing draft; its `position` field uses unified-diff position rather
than a file line.

**Suggested fix:** In Phase 5, prefer `addPullRequestReviewComment` with an explicit
pending-review node ID for new top-level comments. Compute and validate the diff
position, require the returned review and comment states to be `PENDING`, and keep
delete/recreate only as a fallback when the GraphQL append is unavailable.
