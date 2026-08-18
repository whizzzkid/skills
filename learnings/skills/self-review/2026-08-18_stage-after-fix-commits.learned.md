---
skill: wk-self-review
date: 2026-08-18
type: gap
severity: medium
verified-against-source: n/a
---

Staging the pending self-review before the adversarial-review gate guarantees anchor rot when review findings produce commits.

**What happened:** The pending review was staged against the then-current HEAD, then the
adversarial-review gate raised two findings whose fix commit rewrote the same file the review
anchored to. The pending comment's `position` (1) no longer matched its `original_position` (5),
so the whole review had to be deleted and re-staged against the new HEAD — the bodies had to be
preserved and the anchors rebuilt from the new diff hunks.

**Root cause:** The skill treats anchor drift as a recovery path ("Updating an Existing
Self-Review") rather than an ordering constraint. On any PR whose review yields fixes, staging
before the gate makes the drift certain, not incidental.

**Suggested fix:** State in Step 4 that the pending review is staged only after every
finding-response commit for the round has landed — the "finish every known commit-producing
action in the current round first" rule should name the adversarial-review gate explicitly as
one of those actions. Add a mandatory pre-handoff drift check (`position` vs
`original_position` on every staged comment) so a stale review is never left for the user to
submit.
