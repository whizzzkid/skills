---
skill: wk-gh
date: 2026-11-20
type: surprise
severity: medium
verified-against-source: yes
---

While your own self-review is pending, REST replies to review threads fail with 422.

**What happened:** A pending self-review (staged, not submitted) existed on the PR. Replying to a bot's review thread with `POST /pulls/{n}/comments/{id}/replies` returned 422: "user_id can only have one pending review per pull request".

**Root cause:** A reply creates a review comment, which needs a review. The user already holds a pending review, and a user can have only one pending review per pull request.

**Suggested fix:** Before replying to a thread on a PR with a pending self-review, choose one of three routes:
- add the reply into the pending review and accept that it stays hidden until Submit;
- post a PR conversation comment that references the thread, and resolve the thread through GraphQL;
- ask the user to submit the self-review first.

Detect the pending review up front (`GET /pulls/{n}/reviews`, `state == PENDING`), so the 422 never fires.
