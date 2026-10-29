---
class: principle
source: learnings/skills/gh/2026-10-29_pending-review-blocks-replies.learned.md
date: 2026-10-29
severity: medium
---

# A user's pending review blocks thread replies — work around it, never touch it

**Rule** — On REST `/replies` 422 `user_id can only have one pending review per pull request`, never submit or delete
the user's pending review. React on each thread, post one issue comment addressing every blocked thread, and tell the
user their draft is what blocks replies.

**Why** — Replies are created inside a review; the API refuses a second pending review. The draft is the user's
unpublished work, so submitting or deleting it to unblock destroys or publishes it without consent. The installed
fallback lived only in a reference, so the run hit the 422 without the route in view (escalated: reference →
`SKILL.md` Step 3).

**Where** — `skills/gh/SKILL.md` Step 3; `references/pending-review-mechanics.md` → REST block (batch fallback +
never-delete clause).
