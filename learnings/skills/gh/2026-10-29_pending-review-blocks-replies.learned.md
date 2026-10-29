---
skill: wk-gh
date: 2026-10-29
type: surprise
severity: medium
verified-against-source: yes
---

A user's own pending (unsubmitted) review on a PR blocks creating review-comment replies via the API.

**What happened:** `POST pulls/<n>/comments/<id>/replies` returned 422 "user_id can only have one pending review per
pull request" because the user had an unsubmitted review on that PR.

**Root cause:** Replies are created as part of a review; the API refuses to open a second pending review.

**Suggested fix:** On that 422, never submit or delete the user's pending review. Fall back to reactions plus a single
issue comment that addresses each thread, and tell the user their pending review is blocking thread replies.
