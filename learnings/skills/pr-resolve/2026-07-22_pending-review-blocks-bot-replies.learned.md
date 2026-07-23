---
skill: wk-pr-resolve
date: 2026-07-22
type: pattern
severity: low
---

A pending self-review blocks REST replies to bot-review inline comments (422), and the GraphQL resolve path is the correct workaround — confirmed working end to end.

**What happened:** After fixing two bot-reviewer findings, `POST /pulls/{n}/comments/{id}/replies` returned `422 "user_id can only have one pending review per pull request"` because the author already had a pending (unsubmitted) self-review staged on the same PR. Posting a normal issue-comment (conversation surface) summarizing both fixes, then resolving each thread via the `resolveReviewThread` GraphQL mutation, worked cleanly and required no REST review-comment write at all.

**Root cause:** GitHub's REST reply-to-review-comment endpoint implicitly creates a new pending review under the same user if one is missing, but errors instead of reusing an existing pending review. Thread resolution (GraphQL) is a separate mutation from comment creation and is unaffected by an existing pending review, so it's not blocked the same way.

**Suggested fix:** When a pending self-review is detected at fetch time (Step 3's gate), route bot/reviewer-finding replies to the conversation (issue-comment) surface instead of attempting a review-comment reply, then resolve the affected thread(s) via GraphQL — do not treat the 422 as a stop condition requiring the pending review to be submitted or deleted first.
