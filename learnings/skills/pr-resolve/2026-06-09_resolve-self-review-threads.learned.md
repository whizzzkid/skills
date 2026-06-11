---
skill: wk-pr-resolve
date: 2026-06-09
type: gap
severity: medium
---

Orientation pass must resolve author's own self-review threads before declaring the PR merge-ready.

**What happened:** After `wk-self-review` posts inline comments as a submitted `COMMENTED` review, those threads remain `isResolved: false`. Branch protection counts every unresolved thread regardless of authorship, so the PR could not merge until they were resolved separately.

**Root cause:** The orientation/orientation-check step in `wk-pr-resolve` only looked at reviewer-authored threads; self-review threads were excluded from resolution by Hard Rule 3 ("never resolve self-review threads") even when the author intends them as informational notes, not blocking feedback.

**Suggested fix:** Add a step before the "ready to merge" check: query `reviewThreads` for threads where `isResolved == false` and the root comment author is the PR author (i.e., self-review threads). These are the author's own explanatory notes — resolve them via `resolveReviewThread` GraphQL mutation since the author has signaled intent by submitting the review, not leaving it as PENDING.
