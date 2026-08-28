---
class: principle
---

**Rule** — After any conversation-surface write (issue comment, PR comment),
re-list the surface and confirm the new comment ID appeared and no prior
comment's body length changed.

**Why** — GitHub's REST router silently accepts POST on single-comment
resources as an update (same as PATCH). A misrouted write returns 200 with
the existing comment ID, so `|| fallback` never fires. Pre-capture plus
post-write verification caught a silent overwrite before the user or the
bot's owners noticed.

**Where** — `SKILL.md` Step 3, appended to the "Never POST to
`/issues/comments/{id}`" block.
