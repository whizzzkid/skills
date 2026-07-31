---
skill: wk-pr-review
date: 2026-07-31
type: gap
severity: high
verified-against-source: yes
---

Recheck the live PR head immediately before creating a pending review.

**What happened:** A commit landed after context collection but before the review POST. GitHub attached the new pending
review to that latest commit, while the investigation had been performed against the previous head.

**Root cause:** The skill verifies local HEAD against the PR head during intake, but has no second live-head gate immediately
before creating the draft review. The API defaults the draft to the current PR head, so a mid-review push creates a silent
evidence-to-target mismatch.

**Suggested fix:** Immediately before the POST, re-fetch `headRefOid` and compare it with the investigated SHA. On mismatch,
inspect the delta, revalidate findings and anchors, then render the payload against the new head or stop without posting.
