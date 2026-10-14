---
skill: wk-pr-review
date: 2026-10-09
type: correction
severity: medium
verified-against-source: n/a
---

The agent stopped at Phase 4's "wait for user approval" and did not create the pending review that Phase 5 says to create automatically.

**What happened:** The agent showed the numbered findings summary and asked "post as pending review?". It did not
POST the review. The user had to ask why it wasn't posted.

**Root cause:** Phase 4 ends with "present summary and wait for user approval", and Phase 5's HARD RULE says to
create the pending review automatically unless the user said "don't post"/"wait". The two lines conflict, and the
agent followed the earlier, softer one.

**Suggested fix:** Change the end of Phase 4 to: "Present the numbered summary, then go straight to Phase 5. The
review is pending, so the user still decides whether to submit it. Wait only if the user said don't post, wait, or let
me review first." It also worked to retry the identical POST once after a hook-rewrite denial, as `wk-env` 3.6
describes.
