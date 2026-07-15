---
skill: wk-pr-review
date: 2026-07-15
type: gap
severity: medium
---

Could not add new inline comments to an already-created pending review via the REST comments endpoint — it returned 422 "user_id can only have one pending review per pull request."

**What happened:** After posting a pending review, a follow-up asked to add more inline comments to it. `POST /pulls/{n}/comments` (and the GraphQL reply mutation) reject the write because a pending review already exists. The working path was to DELETE the pending review and recreate it with the full comment set in one `reviews` POST.

**Root cause:** GitHub does not let you append draft comments to an existing pending review through the standalone comments endpoint; comments must be supplied in the `comments[]` array of the review-create call.

**Suggested fix:** In Phase 5, document that adding comments to an existing pending review requires deleting it (`DELETE /pulls/{n}/reviews/{id}`) and re-POSTing the review with all comments; rebuild every comment from scratch since pending-review comments return `line: null` and can't be round-tripped.
