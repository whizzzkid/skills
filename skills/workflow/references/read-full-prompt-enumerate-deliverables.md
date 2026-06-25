---
class: principle
---

**Rule:** Read the full prompt to the end and enumerate every deliverable before
acting. A message opening with a noun task ("create a ticket") and closing with an
imperative ("fix this") is two work items — commit to the full list before
executing the first; never stop after the first deliverable.

**Why:** The agent parsed the first deliverable and stopped, missing a trailing
implementation directive, forcing the user to repeat the request. This gates
*reaching* planning; wk-plan Step 0 then handles multi-deliverable granularity
once planning starts.

**Where:** Continuity Rules (top of skill), new bullet before the interruption
and final-completeness rules.
