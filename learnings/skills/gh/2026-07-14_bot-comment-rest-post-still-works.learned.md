---
skill: wk-gh
date: 2026-07-14
type: correction
severity: medium
---

After a bot replaces its review, `GET /pulls/{n}/comments/{id}` 404s for the old `databaseId`, but `POST /pulls/{n}/comments/{id}/replies` to that same ID still succeeds.

**What happened:** A documented caveat says a bot-replaced review's REST `databaseId` "404s for all ops," implying replies must go through GraphQL. Verified `GET` does 404 on the stale ID, but a `POST` to `/pulls/{n}/comments/{id}/replies` on the identical ID returned 201 and created a real threaded reply. The GraphQL `addPullRequestReviewComment` mutation with `inReplyTo` also failed, but with a `FORBIDDEN` permissions error unrelated to the ID being stale — a token/scope issue, not evidence the ID itself is invalid.

**Root cause:** The caveat over-generalized from a single observed 404 on `GET` to "all ops," without testing whether a write endpoint on the same ID behaves differently. GitHub's REST API apparently still accepts writes against a review comment ID that no longer resolves for reads once a bot has replaced its review.

**Suggested fix:** Narrow the caveat to "GET 404s" and always try the REST `/replies` POST directly on the visible `databaseId` before falling back to GraphQL — don't assume a failed `GET` rules out a working `POST`.
