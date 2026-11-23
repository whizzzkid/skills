---
skill: wk-gh
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

A GraphQL thread reply posted while the author has a pending review attaches to that pending review and stays invisible.

**What happened:** The agent staged a pending self-review, then replied to a bot thread via
addPullRequestReviewThreadReply. The reply's state came back PENDING inside the self-review.

**Root cause:** Confirmed by querying the reply node: its pullRequestReview was the author's PENDING review.

**Suggested fix:** Before any thread reply, query the author's reviews; if one is PENDING, either reply after the user
submits it or tell the user the reply will publish with that draft. Never resolve the thread until the reply is visible.
