---
skill: wk-pr-resolve
date: 2026-07-14
type: gap
severity: medium
---

An author's PENDING (unsubmitted) self-review blocks both inline reply creation and REST review-comment edits on the PR.

**What happened:** With the PR author's own review still in PENDING state, `POST /pulls/{n}/comments` (inline reply) returned 422 "user_id can only have one pending review per pull request", and `PATCH` on a review comment belonging to that pending review returned 404. This blocked the normal "reply inline + resolve thread" path and the "edit my stale self-review annotation" path.

**Root cause:** GitHub scopes inline review comments and their edits through the review object; while the author's review is unsubmitted, its comments are not addressable via the standard REST review-comment endpoints, and no second pending review (the reply) can be created.

**Suggested fix:** wk-pr-resolve should note this failure mode and its route-around: resolve the thread via GraphQL `resolveReviewThread` (works independently of pending-review state), post the substantive reply as a top-level conversation comment (`POST /issues/{n}/comments`) noting the constraint inline, and defer any edit to the author's own annotation until the pending self-review is submitted or dismissed (never submit it to unblock — Hard Rule 13).
