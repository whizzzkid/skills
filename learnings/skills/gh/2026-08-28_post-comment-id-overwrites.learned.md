---
skill: wk-gh
date: 2026-08-28
type: correction
severity: high
verified-against-source: yes
---

POST to `/repos/{o}/{r}/issues/comments/{id}` overwrites the comment, it does not create a reply

**What happened:** While replying to a {bot} finding on a PR conversation surface, the agent
POSTed a body to `/repos/{o}/{r}/issues/comments/{id}` expecting either a reply-create or a
loud error triggering a fallback. GitHub routed the POST as an UPDATE (same as PATCH): it
silently replaced the {bot}'s review-summary comment body and returned 200 with the existing
comment id, so the `|| fallback` never fired. The original body had been captured earlier in
the session, so it was restored via PATCH and the reply re-posted correctly.

**Root cause:** GitHub's REST router accepts POST on the single-comment resource and treats it
as an edit; the endpoint is not a reply surface. Conversation comments have no reply
subresource at all — a "reply" is always a new comment via
`POST /repos/{o}/{r}/issues/{n}/comments`.

**Suggested fix:** In wk-gh Step 3, add: never POST/PATCH `/issues/comments/{id}` except to
deliberately edit a comment you own; conversation replies go only to
`/issues/{n}/comments`. After any conversation write, verify by re-listing: a NEW comment id
must appear and the prior comment's body length must be unchanged. Before any write near
another author's comment, capture its full body first so an accidental overwrite is
recoverable.
