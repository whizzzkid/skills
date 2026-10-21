---
class: principle
source: learnings/skills/pr-resolve/2026-10-20_takeover-own-review-threads.learned.md
date: 2026-10-20
severity: medium
---

## The current user's pre-takeover review threads are reviewer feedback

The user reviewed a PR, then took it over. Hard Rule 6 (skip threads by PR author or current user)
filtered out those submitted review threads, so they stayed unreplied and unresolved even though the
takeover had fixed them.

**Principle:** self-review exclusion targets self-documenting comments on one's own PR. Role is decided
at review time, not now — a review submitted while the user was not yet an author is reviewer feedback.

**Discriminators kept:**

- Review `submittedAt` precedes the current user's first commit on the branch (takeover, co-author).
- Review state `CHANGES_REQUESTED` — GitHub does not allow requesting changes on one's own PR, so it
  proves a reviewer role.

**Rejected suggestion:** treating `COMMENTED` or `DISMISSED` reviews "with findings" as reviewer feedback.
Self-review posts are `COMMENTED` reviews, so that test would pull ordinary self-documentation back into
triage; the time-of-joining test already covers the takeover case.

**Landed in:** `SKILL.md` Hard Rule 6 exception; Step 1 co-author line and Step 3 classification point to it.
