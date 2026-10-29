---
class: principle
---

**Rule** — While the author's own review stays PENDING, its inline comments are not
addressable via standard REST: `POST /pulls/{n}/comments` returns 422 (`one pending
review`) and `PATCH` on a comment belonging to that pending review returns 404. Never submit or delete it to unblock; stop and ask the user to
submit or discard it, or approve adding the replies to it, then reply in every thread
(superseded 2026-10-29: the top-level issue-comment route-around put answers off-thread).

**Why** — GitHub scopes inline review comments through the review object; an unsubmitted
review's comments are not writable via the standard REST review-comment endpoints, and no
second pending review (the reply) can be created.

**Where** — `skills/gh/SKILL.md` pending-review block; route-around cross-referenced from
`skills/pr-resolve/SKILL.md` Step 3 + `references/commands.md` §pending.
