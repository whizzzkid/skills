---
class: principle
---

**Rule** — On a blocked verdict, when a confirmed blocker's remedy is a nontrivial
new mechanism/feature or design change (not a contained fix), offer "narrow/revert
the triggering change + defer the deeper fix to a follow-up PR" as a first-class
resolution alongside fix-inline. Prefer it when the blocker sits in complexity the
current PR introduced.

**Why** — The fix-loop optimizes "make the diff correct" with no notion of "should
this fix live in THIS PR." Treating every CONFIRMED blocker as mandatory-inline let
the review process itself drive scope creep — e.g. a dismissible TOCTOU already
backstopped by a reconcile job was built into a full new concurrency mechanism.
Removing scope-creep code often beats adding more code to make it correct.

**Where** — `skills/adversarial-review/SKILL.md` Step 7 (Fix Loop), "On blocked
verdict" off-ramp bullet.
