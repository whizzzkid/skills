---
skill: wk-retro
date: 2026-05-27
type: gap
severity: high
---

Retro Step 4 must invoke wk-learn for each skill gap/correction, not just log it to retro-log.md.

**What happened:** Session retro wrote a narrative entry to `~/.claude/memory/retro-log.md` but never invoked `wk-learn` for any skill learnings. The promotion table in Step 4 says "skill gaps → invoke wk-learn" but the agent treated writing retro-log narrative as sufficient.

**Root cause:** Step 4's table distinguishes skill learnings (wk-learn → $WK_SKILLS_HOME) from other promotions (memory files), but the agent stops after writing the narrative log and never executes the wk-learn calls.

**Suggested fix:** Step 4 should have an explicit sub-step: "For each Tool/Skill Gap or Correction bullet, call Skill(wk-learn, args='<skill-name> <description>'). Writing to retro-log.md is the narrative record; wk-learn is the actionable record. Both are required."
