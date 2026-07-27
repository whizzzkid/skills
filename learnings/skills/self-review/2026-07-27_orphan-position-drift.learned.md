---
skill: wk-self-review
date: 2026-07-27
type: gap
severity: medium
verified-against-source: n/a
---

Orphan detection on a pending review needs a position check, not only a `commit_id` comparison.

**What happened:** A pending review was staged several commits back. Its `commit_id` still differed
from HEAD, which caught it — but the comments themselves had also drifted: their anchors no longer
pointed at the lines whose rationale they explained. Inspecting the comments to confirm the drift
was harder than expected, because a comment belonging to a pending review reports `line: null`.

**Root cause:** The staleness check is written against the review object's `commit_id`. Comment-level
drift is a separate axis — anchors can rot while a review is still nominally current — and the
obvious field for checking it (`line`) is null for pending comments, so the drift is invisible unless
`position` is compared against `original_position`.

**Suggested fix:** In the "Updating an Existing Self-Review" step, add: compare each comment's
`position` against its `original_position` in addition to comparing the review's `commit_id` against
HEAD. Note explicitly that pending comments report `line: null`, so `position`/`original_position`
are the only usable drift signal. Any mismatch on either axis means delete and re-stage. Also
recommend preserving the comment bodies to a temp file before the DELETE — it makes the delete safe
and lets the re-staged version correct any bullet that has gone factually stale in the meantime.
