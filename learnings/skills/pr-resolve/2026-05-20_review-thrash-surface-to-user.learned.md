---
skill: wk-pr-resolve
date: 2026-05-20
type: gap
severity: medium
---

When 3+ bot re-review cycles fire on the same PR without progress, surface this as a review-thrash signal to the user rather than continuing to fix and push.

**What happened:** pr-resolve ran multiple fix-and-push cycles; each push triggered a fresh bot review that re-raised the same or similar findings. The skill continued looping without flagging the thrash pattern.

**Root cause:** pr-resolve's post-push loop has no counter for consecutive bot re-reviews on the same concern class. Three identical re-fires indicates either the fix is wrong, the bot has a stale snapshot, or the concern is structural and not fixable in this PR.

**Suggested fix:** Track `(path_prefix, concern_class)` pairs across bot review rounds. After 3 re-fires on the same class, stop and ask the user: "Bot has re-raised the same concern 3 times. Options: (a) investigate root cause, (b) defer to follow-up ticket, (c) dismiss with rationale."
