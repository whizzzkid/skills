---
skill: wk-self-review
date: 2026-10-20
type: gap
severity: low
verified-against-source: n/a
---

Re-staging after new commits assumed the prior self-review was still pending; it had been submitted, so the re-stage duplicated its comments.

**What happened:** No pending review was found to delete, and the full payload was re-posted as a new pending review.

**Root cause:** "Updating an Existing Self-Review" only covers the pending case.

**Suggested fix:** List reviews first; if the prior one is submitted, stage only new or changed notes and reply on stale threads instead of re-posting.
