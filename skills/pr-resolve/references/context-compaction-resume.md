---
class: principle
skill: wk-pr-resolve
date: 2026-06-18
---

**Rule:** When a session is resumed from a context-compaction summary mid-skill,
the first action is a resume protocol: identify the last completed step from the
summary, confirm the resume point (default: next uncompleted step), skip earlier
steps, re-run sync/fetch steps that may have gone stale, and never silently drop
tail steps (CI wait loop, new-comment scan, retro) just because they were absent
from the compacted summary.

**Why:** Without an explicit resume protocol, resumption defaults to ambient
context and misplaces the cursor anywhere from Step 1 to just before compaction.
A real session skipped the CI loop, new-comment scan, and retro until the user
asked whether the loop was supposed to run.

**Where:** New Resume Protocol block near the top of the skill, activated on a
detected compaction summary.
