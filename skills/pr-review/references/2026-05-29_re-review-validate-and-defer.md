---
class: principle
date: 2026-05-29
skill: wk-pr-review
---

# Re-review: validate fixes, handle deferrals, dedup own threads

- **Rule:** On a re-review, validate a claimed fix against current code
  before acknowledging; classify author deferrals to a ticket as 👍-only
  (nudge in-PR when the deferred concern is a `blocker`); answer author
  follow-up questions with the concrete action required; dedup the
  re-review's new findings against your own prior threads (reply, don't
  re-post).
- **Why:** A modified file proves the author tried, not that the concern is
  resolved — silent trust ships the original bug. Deferrals had no outcome
  before, so critical risks could slide. New findings overlapping the
  user's own prior threads produced duplicate top-level comments.
- **Where:** Phase 2 "Re-review follow-up" — classification table (new
  "Deferred to a future ticket" row, strengthened "Fix applied" and
  "Author asked a question" rows), "Validate a claimed fix", "Nudge on
  critical deferrals", "Staging vs live", and "Dedup re-review findings
  against your own prior threads".
- **Note:** Thread replies + emoji reactions cannot ride in a pending
  (draft) review (GitHub 422 on `in_reply_to`, reactions post immediately).
  They are live actions gated on explicit approval; only new top-level
  findings stay pending. Reactions reuse the canonical API in
  `wk-pr-resolve`.
