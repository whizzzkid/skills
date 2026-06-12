---
skill: wk-adversarial-review
date: 2026-06-11
type: pattern
severity: low
---

Subjective design-quality bot findings that contradict an already-accepted refactor are judgment-class dismissals, not pre-flight sweep gaps.

**What happened:** A post-push re-review re-raised three Minor design-opinion
findings ({bot}: abstraction-quality, type-precision, logic-errors-dataflow)
on a struct whose shape had been deliberately refactored and accepted earlier
in the same session. One finding explicitly proposed reversing the accepted
refactor (collapse structured fields back into a precomputed string).

**Root cause:** These are taste/structure opinions, not mechanical defects.
`wk-adversarial-review`'s Step 2 sweeps target concrete classes (vuln-class
drift, stale comments, hardcoded base, enumeration sync). A bot's
"consider deriving X from Y" or "this struct is over-engineered" cannot and
should not be pre-empted by a grep — trying to would produce false positives
on every intentional design choice.

**Suggested fix:** No new mechanical sweep. Treat a post-push finding that
contradicts a design decision accepted earlier in the same session as the
convergence/terminal-thrash signal (already in `wk-pr-resolve` Step 4):
dismiss-with-rationale and resolve, do not re-churn the struct. The baseline
held — capture as a "design-opinion findings are judgment-class" reminder so
future runs don't route them into another fix cycle.
