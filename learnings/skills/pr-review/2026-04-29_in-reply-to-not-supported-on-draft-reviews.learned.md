---
skill: wk:pr-review
date: 2026-04-29
type: gap
severity: medium
---

REST `POST /pulls/{n}/reviews` rejects `in_reply_to` on draft review comments.

**What happened:** Phase 6 attempted to bundle a bot-thread reply into the
pending-review payload using `in_reply_to: <comment_id>` per the skill's
guidance that "reply suggestions inherit the parent's anchor." GitHub's
REST API returned 422:
`Field is not defined on DraftPullRequestReviewComment`.
The skill also suggests posting bot replies via
`POST /comments/{id}/replies`, but that endpoint posts immediately (not
draft) and was correctly blocked by the harness when the user had only
authorized creating a "pending review."

**Root cause:** Two distinct GitHub APIs are conflated in the skill:
1. `POST /pulls/{n}/comments` (single PR comment outside any review) —
   does support `in_reply_to_id` for threading, posts immediately.
2. `POST /pulls/{n}/reviews` (pending review payload) — does **not**
   support `in_reply_to` on its `comments[]` entries; each entry must
   be a top-level comment with `path` + `line` + `side`.

The skill's "Bot replies count toward the 6-comment cap, same as new
top-level comments" wording implies bot replies can ride along in the
pending review. They cannot — they must either be posted live (needs
explicit user authorization) or folded into the review body as prose.

**Suggested fix:** Update Phase 5/6 of `wk-pr-review/SKILL.md`:
- Note that `in_reply_to` is not a valid field in pending-review comments.
- For bot-thread replies during a pending-review flow, default to one of:
  (a) include the validation note in the review `body` referencing the
      bot's thread anchor (e.g. "Re: bot thread on file:line — ..."), OR
  (b) ask the user for explicit authorization to post the live reply via
      `/comments/{id}/replies` after the pending review is created.
- Make the "counts toward the 6-comment cap" wording conditional on the
  delivery mechanism, since (a) doesn't add a comment at all and (b) is
  posted outside the pending review.
