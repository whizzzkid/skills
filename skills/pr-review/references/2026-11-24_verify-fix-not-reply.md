---
class: principle
---

# Verify "fixed" replies at pattern level; treat 5xx on create as maybe-landed

- **Rule** — On re-review, check every "fixed" reply mechanically at the head blob: grep the finding's pattern across
  the whole changed file and its siblings, diff the fix for rules it newly tightens, and grep dependent artifacts for
  contradictions it creates. Either miss is a partial fix, answered as a reply on the original thread inside the
  pending review (GraphQL `addPullRequestReviewThreadReply` with `pullRequestReviewId`), never a new top-level thread.
  A deferral with no tracking link stays open. A 5xx or timeout on the create POST → list pending reviews before any
  retry.
- **Why** — Fixes often land only on the quoted instance, and a fix that extends a list can leave older restatements
  contradicting it; both keep the original finding open. Per-finding greps found partial fixes the replies called
  fixed. The prior reference said thread actions are always live, but the GraphQL reply input takes a pending review
  ID (schema introspection confirms `pullRequestReviewId`: "the pending review to which the reply will belong"), so a
  reply can stage with the rest of the review; REST review `comments[]` cannot carry replies, so a delete+recreate
  must re-add them. A create POST returned 502 and still created the review; a blind retry 422s or doubles it.
- **Where** — `SKILL.md` Phase 2 "Re-review" bullet and Phase 5 POST HARD RULE (5xx clause);
  [`re-review-follow-up.md`](re-review-follow-up.md) "Verify each fixed reply" and "Where follow-ups go";
  [`posting-pending-review.md`](posting-pending-review.md) "Create pending review"; API mechanics generalized in
  `wk-gh` `references/pending-review-mechanics.md` "Ambiguous create outcome".
