---
skill: wk-gh
date: 2026-07-09
type: correction
severity: high
---

`gh api graphql` mutation `addPullRequestReviewComment` with `inReplyTo` set but `pullRequestReviewId` omitted silently attaches the new comment to an existing PENDING review draft instead of publishing a standalone reply, when the acting user already has a pending review on that PR.

**What happened:** Attempted to post a threaded reply to a bot review comment via the GraphQL `addPullRequestReviewComment` mutation while the acting user (also the PR author) had an unrelated self-review sitting in PENDING state. The mutation succeeded with no error and returned `state: "PENDING"` on the new comment, but this went unnoticed — the comment was invisible to anyone until the human later submitted their own pending review, at which point the unrelated reply was published bundled into that review.

**Root cause:** The GraphQL API auto-attaches an `inReplyTo` comment to the caller's existing pending review when `pullRequestReviewId` is not explicitly provided, rather than erroring or auto-publishing a standalone comment. The REST reply endpoint (`POST /repos/{owner}/{repo}/pulls/{n}/comments/{id}/replies`) behaves differently: it 422s cleanly with a "user_id can only have one pending review" error when a pending review already exists, rather than silently mis-attaching.

**Suggested fix:** Before posting any reply comment via `gh api graphql`, first query `pullRequest.reviews(states: PENDING)` for the acting user. If a pending review exists, either (a) prefer the REST replies endpoint, which fails loudly instead of silently mis-attaching, or (b) surface the pending review to the user and wait for it to be resolved before posting. Never treat a `state: "PENDING"` response from `addPullRequestReviewComment` as success — check the returned `state` field explicitly and treat non-published states as a failure requiring remediation.
