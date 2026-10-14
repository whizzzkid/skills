---
skill: wk-gh
date: 2026-10-09
type: surprise
severity: low
verified-against-source: yes
---

Check a review's `state` right before submitting it; it may already have been submitted in the UI.

**What happened:** The agent was asked to submit a pending review, and its state check moments earlier
said `PENDING`. Both `POST /pulls/{n}/reviews/{id}/events` calls (event `COMMENT`, with and without a
body) returned 422 `"Could not comment pull request review."`. Re-reading the review showed
`state: APPROVED` with a `submitted_at` after the earlier check: {user} had submitted it in the browser
the agent had just opened.

**Root cause:** The review page was open in the browser, so the user could submit it at the same time
as the agent. The 422 message does not say "already submitted", so it reads like a payload error.

**Suggested fix:** On a 422 from `/reviews/{id}/events`, re-GET the review and check
`state`/`submitted_at` before retrying or changing the payload. If it is no longer `PENDING`, report
the submitted state and stop. Never resubmit.
