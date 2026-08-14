---
class: principle
---

# Pending-review mechanics — creation, parse failures, REST block

## Creation responses

- Project only review ID, state, and commit; then GET
  `/pulls/{n}/reviews/{id}/comments` and verify staged comment anchors. Missing
  expansion is never a retry signal.

## Compare-and-recover

- Immediately before POST, re-query the acting user's pending review. A draft
  found then, or HTTP 422 from create, routes to the same recovery: fetch its
  body and review-specific comments, preserve them, build a deduplicated union
  with the proposed draft, then use the calling skill's delete-and-recreate path.
  Never retry create against the stale empty-discovery result.

## Client-side JSON parse failure

- A successful `POST /pulls/{n}/reviews` can return a body a strict decoder
  rejects (`Invalid control character`), so capture the HTTP status separately
  from the body and never infer failure from the parse. On any parse error
  re-query `GET /pulls/{n}/reviews`, filtering `state` and `user.login`, to
  establish ground truth before retrying — a blind retry 422s (`one pending
  review`). Re-parse leniently (`json.loads(..., strict=False)`) rather than
  treating the response as garbage.

## REST block on pending reviews

- While the author's own review stays PENDING, its inline comments are not
  addressable via standard REST: `POST /pulls/{n}/comments` returns 422
  (`one pending review`), and `PATCH` on a comment belonging to that pending
  review returns 404. Resolve the thread via GraphQL `resolveReviewThread`, post
  the substantive reply as a top-level `POST /issues/{n}/comments`, and defer any
  edit to the author's own annotation until the pending review is submitted or
  dismissed — never submit it to unblock.
