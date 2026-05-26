---
class: principle
date: 2026-05-26
source: learnings/skills/pr-review/2026-05-26_pending-review-comments-null-line.md
---

- **Rule:** When verifying inline comments on a PENDING (draft) review via `/pulls/{n}/reviews/{id}/comments`, match on `path` + `body` prefix; do not treat `line: null` / `start_line: null` as a failure signal. The fields resolve only after the review is submitted.
- **Why:** GitHub's REST API does not surface line/position metadata for draft-review comments; a verifier keying on `line` would falsely flag a correctly-posted pending review as broken.
- **Where:** Phase 6 "After posting" — added a "Pending-review verification" note distinguishing draft vs submitted line-field behavior.
