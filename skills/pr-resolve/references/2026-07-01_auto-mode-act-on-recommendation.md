---
class: principle
---

**Rule:** In Auto Mode, a finding for which the agent has a confident,
evidence-backed disposition (apply *or* dismiss) is already decided — route it to
`obvious_fixes[]`, act, and report. Never present an already-recommended
disposition for per-item confirmation, and never batch a "confirm all these?"
prompt.

**Why:** A stated confident recommendation is itself a decision. Re-confirming it
adds no signal and slows the resolution loop; the user reads it as the agent
failing to make calls it is equipped to make. Complements (does not contradict)
the one-comment-at-a-time rule, which still governs genuine judgment calls.

**Where:** wk-pr-resolve Step 5 (Consult → Partition).
