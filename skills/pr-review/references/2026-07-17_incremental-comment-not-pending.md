---
class: principle
---

**Rule:** Gate the post mechanism on review state. No review yet (composing a
complete review) → pending draft. A review already posted/submitted + a new finding
→ post a direct live inline comment (`POST /pulls/{n}/comments` with commit_id +
path + line) or a thread reply (`/comments/{id}/replies`); never open a second
pending review for one incremental finding. Reserve a fresh pending review for an
explicitly requested new complete pass.

**Why:** A whole new draft review for one incremental comment forces a second human
submit, fragments the review into two objects, and stalls a one-line comment behind
the pending-review checkpoint.

**Where:** wk-pr-review Phase 5 — new "Follow-up finding after a review is posted."
