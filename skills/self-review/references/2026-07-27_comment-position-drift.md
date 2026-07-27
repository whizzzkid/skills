---
class: principle
---

# Orphan detection needs a comment-position check, not only `commit_id`

**Rule**

- Compare each comment's `position` against its `original_position` in addition
  to comparing the review's `commit_id` against HEAD. A mismatch on either axis
  means delete and re-stage.
- Never gate comment staleness on `line` — a pending comment reports
  `line: null`, so the two position fields are the only usable drift signal.
- Preserve every comment body to a temp file before issuing the DELETE.

**Why**

- The staleness check is written against the review object, but comment-level
  drift is a separate axis: anchors can rot while a review is still nominally
  current, and a comment whose anchor no longer points at the lines it explains
  is worse than no comment.
- Preserving the bodies first makes the delete safe and lets the re-staged
  version correct any bullet that went factually stale in the meantime.

**Where**

- `SKILL.md` → *Updating an Existing Self-Review* → HEAD-rewritten step.
