---
skill: wk-pr-resolve
date: 2026-06-18
type: gap
severity: high
---

No guidance for resuming a mid-skill session after context compaction.

**What happened:** A `wk-pr-resolve` session hit context limits mid-execution and was compacted. On resumption, the agent had no instruction for identifying the last completed step, so it lacked a clear recovery path. Steps 9–11 (CI wait loop, new-comment scan, retro) were silently skipped until the user explicitly asked whether the loop was supposed to run.

**Root cause:** The skill has no explicit "resume protocol" — no instruction to check the last completed step from the conversation summary or compaction artifact and pick up from there. Without it, resumption defaults to ambient context which may misplace the cursor anywhere from Step 1 to just before compaction.

**Suggested fix:** Add a **Resume Protocol** block near the top of the skill, activated when a session-compaction summary is detected in context:
1. Identify the last completed step number from the summary.
2. Confirm with the user which step to resume from (default: next uncompleted step).
3. Skip all steps before the resume point; re-run sync/fetch steps that may have gone stale.
4. Never silently drop tail steps (CI loop, retro) just because they weren't in the compacted summary.
