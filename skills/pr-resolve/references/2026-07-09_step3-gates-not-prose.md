---
skill: wk-pr-resolve
class: principle
---

**Rule** — Step 3 must EMIT two lines before triage, not merely follow prose:
(1) a three-surface fetch tally `surfaces: inline=N reviews=N conversation=N`,
and (2) a pending-self-review verdict `pending-self-review: yes|no → reply route`
that pre-selects the reply path.

**Why** — This is a high-severity re-violation: both rules were already distilled
(fetch all three surfaces; pre-check pending self-review at fetch time) yet both
failed to steer in one run — a bot's bulk-findings conversation comment was
missed until the user asked, and a pending review surfaced only as a 422 at reply
time. Prose folded once is still skipped under context pressure: a single
non-empty surface satisfies the felt goal of "found the feedback," and a state
fetched but not wired to a decision emits nothing to check. A step the agent must
produce output for resists context-pressure skipping better than a sentence it
must remember. Escalation notch: restructure so the rule is structurally
impossible to skip.

**Where** — wk-pr-resolve Step 3 (emitted gate).
