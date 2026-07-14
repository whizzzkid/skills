---
class: principle
---

**Rule** — While the author's own review stays PENDING, its inline comments are not
addressable via standard REST: `POST /pulls/{n}/comments` returns 422 (`one pending
review`) and `PATCH` on a comment belonging to that pending review returns 404. Resolve
the thread via GraphQL `resolveReviewThread`, post the substantive reply as a top-level
`POST /issues/{n}/comments`, and defer editing the author's own annotation until the
pending review is submitted or dismissed — never submit it to unblock.

**Why** — GitHub scopes inline review comments through the review object; an unsubmitted
review's comments are not writable via the standard REST review-comment endpoints, and no
second pending review (the reply) can be created.

**Where** — `skills/gh/SKILL.md` pending-review block; route-around cross-referenced from
`skills/pr-resolve/SKILL.md` Step 3 + `references/commands.md` §pending.
