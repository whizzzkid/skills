---
class: principle
---

**Rule:** A referenced sibling-skill action flow is an instruction the orchestrator
*executes* after gathering, not framing to describe. When a gathering subagent
detects a missing scheduled item and a documented creation flow exists, the
orchestrator performs the write before compiling output — falling back to a
passive flag only when the write is impossible (no access, no slot).

**Why:** Subagents are read-only by contract; the write action lives with the
orchestrator. Treating a `wk-cal` §-reference as informational context produced a
passive "no prep/scorecard block scheduled" TODO instead of the block itself,
leaving the user to do the work the skill was meant to automate.

**Where:** `start` orchestrator step, after agents return and before writing
`live.md` (parallel to the merged-PR auto-transition action).
