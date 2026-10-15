---
skill: wk-gh
date: 2026-10-14
type: gap
severity: low
verified-against-source: yes
---

A REST reply to a review comment fails with 422 while the user has their own pending review on the PR.

**What happened:** `POST /pulls/{n}/comments/{id}/replies` returned `user_id can only have one pending review per pull
request` because a staged self-review was pending. The thread had already been resolved in the same chained command, so
it briefly sat resolved with no reply.

**Root cause:** REST replies create an implicit pending review, which collides with the existing one.

**Suggested fix:** Before replying, query for an existing PENDING review. If one exists, use GraphQL
`addPullRequestReviewThreadReply` with that `pullRequestReviewId`; the reply then publishes with that review. Resolve
the thread only after the reply call succeeds, in a separate step.
