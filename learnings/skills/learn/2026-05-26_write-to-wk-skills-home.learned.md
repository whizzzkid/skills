---
skill: wk-learn
date: 2026-05-26
type: correction
severity: high
---

Learnings must be written to $WK_SKILLS_HOME, not ~/.claude/memory/.

**What happened:** After a skill run, the learning was written to ~/.claude/memory/ because the agent followed the CLAUDE.md "all memories go to ~/.claude/memory/" rule.

**Root cause:** Conflict between the global memory rule and wk-learn's explicit $WK_SKILLS_HOME destination. The agent defaulted to the memory rule instead of the skill's explicit instruction.

**Suggested fix:** wk-learn's Step 3 destination ($WK_SKILLS_HOME/learnings/skills/...) is authoritative and overrides the global memory rule. Skill learnings are not agent memory — they are skill improvement artifacts. Never redirect them to ~/.claude/memory/.
