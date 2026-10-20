---
skill: wk-gh
date: 2026-10-20
type: surprise
severity: medium
verified-against-source: yes
---

Create-review POST rejects file-level comments.

**What happened:** A comment with `subject_type: file` in the `comments[]` of `POST pulls/{n}/reviews` returned 422 ("subjectType not defined on DraftPullRequestReviewComment; position expected not null").

**Root cause:** Draft review comments only accept line/position anchors; file-level comments exist only on the single-comment endpoint.

**Suggested fix:** Off-diff findings go in the review body (one sentence) or a separate live file-level comment after creation; never in the create payload.
