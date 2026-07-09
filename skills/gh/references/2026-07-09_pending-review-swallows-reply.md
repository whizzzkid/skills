---
class: principle
skill: wk-gh
date: 2026-07-09
severity: high
---

- **Rule:** Before posting a reply comment, check whether the acting user has a
  PENDING review on the PR. If one exists, use the REST `/replies` endpoint
  (fails loudly with 422 `user_id can only have one pending review`) or surface
  the pending review and wait — never post via the GraphQL
  `addPullRequestReviewComment` mutation. Never treat a `state: "PENDING"`
  response from a reply mutation as success; any non-published state is a failure.
- **Why:** A threaded reply posted via `addPullRequestReviewComment` with
  `inReplyTo` set but `pullRequestReviewId` omitted was silently attached to the
  caller's unrelated pending self-review instead of published. The mutation
  returned no error and `state: "PENDING"`; the reply stayed invisible until the
  human later submitted their pending review, which bundled the unrelated reply
  into it. The REST `/replies` endpoint 422s cleanly in the same situation.
- **Where:** Step 3 reply-comment guidance — added the pending-review pre-check,
  the loud-failure REST preference, and the explicit `state`-not-PENDING check.
