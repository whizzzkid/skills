---
skill: wk-pr-review
date: 2026-07-17
type: correction
severity: medium
---

Once a review is posted/submitted, add follow-up findings as direct inline comments — don't open a second pending review.

**What happened:** After the review was submitted, a single new finding surfaced. I created a fresh *pending* review to carry that one inline comment, forcing the user to submit a second draft for one comment.

**Root cause:** The pending-review flow is the right container for a *complete* review being assembled for one human submit. For an incremental finding on an already-submitted review, a whole new draft review is friction: it needs a separate submit, fragments the review into two objects, and stalls a one-line comment behind the pending-review checkpoint.

**Suggested fix:** Gate the mechanism on review state. If no review exists yet (composing a complete review) → pending draft, per Phase 5. If a review is already posted/submitted and you have new findings → post the inline comment(s) directly: a live single inline comment (`POST /pulls/{n}/comments` with commit_id + path + line) or a reply on the relevant thread (`POST /pulls/{n}/comments/{id}/replies`). Reserve a new pending review only when the user explicitly asks for a fresh complete review pass.
