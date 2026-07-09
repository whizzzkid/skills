---
skill: wk-pr-resolve
date: 2026-07-09
type: gap
severity: high
---

Two already-distilled Step 3 rules failed to steer in the same run, indicating they read as advisory prose rather than enforced gates.

**What happened:** Despite existing `.learned.md` distillations for (a) "fetch all three feedback surfaces before triage" and (b) "pre-check the author's pending self-review at fetch time," this run triaged only the inline surface (missing a bot's bulk-findings conversation comment until the user asked) and discovered the pending self-review only via a 422 at reply time.

**Root cause:** Both rules live as narrative sentences inside Step 3. Under context pressure a single non-empty surface satisfies the felt goal of "found the feedback," and the pending-review state fetched in `/reviews` is not wired into a decision gate. Prose that has already been folded once is still being skipped — the fix is not another duplicate learning.

**Suggested fix:** Convert both into explicit, checkable gates the run must emit before triage: a printed three-surface fetch tally (inline / review-bodies / conversation, with counts) and a printed pending-self-review verdict that pre-selects the reply route. A step the agent must produce output for resists context-pressure skipping better than a sentence it must remember.
