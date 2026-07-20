---
skill: wk-adversarial-review
date: 2026-07-20
type: gap
severity: medium
---

A confirmed blocker whose fix is a new mechanism should bias toward a follow-up PR, not an inline build-out that grows the PR under review.

**What happened:** The adversarial-review gate repeatedly surfaced real, code-confirmed blockers on a narrow stacked PR. Each confirmed blocker made "just ship it" feel unsafe, so each was fixed inline — including one where the underlying finding was a race window already backstopped by an existing reconcile job (legitimately dismissible), yet the fix built out a full new deferred-write concurrency mechanism. The gate correctly caught bugs, but its "blocked → fix atomically → re-review until clear" loop had no off-ramp that distinguishes "narrow fix required for this PR" from "this is a new feature that belongs in its own PR," so the review process itself drove scope creep.

**Root cause:** The verdict/fix-loop optimizes for "make the diff correct" with no notion of "should this fix live in THIS PR at all." A CONFIRMED blocker is treated as mandatory-inline, even when the correct resolution is to shrink the diff (revert the scope-expanding change) and defer the deeper fix to a follow-up PR.

**Suggested fix:** When a confirmed blocker's remedy is a nontrivial new mechanism/feature or design change rather than a contained fix, offer "defer to a follow-up PR (and revert/narrow the triggering change here)" as a first-class resolution alongside fix-inline — and prefer it when the blocker sits in scope-creep the current PR introduced. A blocker in newly-added, non-essential complexity is often best resolved by removing that complexity from this PR, not by adding more code to make it correct.
