---
class: principle
---

**Rule** — Before adding code to handle a problem, evaluate whether removal,
exclusion, or simplification eliminates it entirely — the fix with zero new
failure modes.

**Why** — The default agent behavior is to solve forward (add code to handle
the condition). Subtractive fixes (e.g., excluding a file from a check's
input set) are often smaller, carry no new failure modes, and avoid
compounding complexity across successive fix PRs.

**Where** — `wk-workflow` Phase 2, pre-execution checkpoint.
