---
skill: wk-sitrep
date: 2026-07-13
type: gap
severity: medium
---

`start` flagged a missing interview prep/scorecard block instead of creating it.

**What happened:** The Calendar+Granola+Drive agent correctly detected an interview meeting the next day with no prep or scorecard block scheduled. Instead of creating the blocks, the run rendered a passive "no prep/scorecard block scheduled" item in `live.md` and left it for the user to resolve manually.

**Root cause:** The skill instructs invoking `wk-cal` §Interview Prep Scan before launching agents, but that reference was treated as informational context for framing the flag rather than as an action to execute. The gathering-subagent contract also states subagents return structured data only and never write — which is correct for the *gathering* agent, but the orchestrator (main context) still owns creating the blocks afterward, and that follow-up action was skipped.

**Suggested fix:** After the Calendar agent reports an interview with no prep/scorecard block, the orchestrator (not the subagent) should call `wk-cal`'s block-creation flow directly — create the 15-min prep block before and 30-min scorecard block after (scanning forward in 30-min increments if the immediate post-slot is busy, per wk-cal) — before compiling `live.md`. Only fall back to a flagged ASAP item if calendar write access is unavailable or no same-day scorecard slot exists.
