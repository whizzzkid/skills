---
class: principle
severity: high
source: learnings/skills/gh/2026-08-28_post-comment-id-overwrites.md
---

## POST to `/issues/comments/{id}` silently overwrites

- **Scenario:** Agent POSTed a reply body to `/repos/{o}/{r}/issues/comments/{id}`
  expecting reply-create or a loud error triggering fallback. GitHub treated POST
  as UPDATE (same as PATCH), silently replacing the target comment's body;
  rc 200 + existing id, so `|| fallback` never fired.
- **Root cause:** GitHub's REST router accepts POST on a single-comment resource as
  an edit. Conversation comments have no reply subresource — a reply is always a
  new comment via `POST /repos/{o}/{r}/issues/{n}/comments`.
- **Fix:** Never POST/PATCH to `/issues/comments/{id}` except to deliberately edit
  a comment you own. Conversation replies go only through
  `/issues/{n}/comments`. After any conversation write, verify the new comment id
  appeared and prior comment body length is unchanged. Before any write adjacent
  to another author's comment, capture its full body for recovery.
- **Landed in:** `SKILL.md` Step 3 — "Never POST to `/issues/comments/{id}`" block.
