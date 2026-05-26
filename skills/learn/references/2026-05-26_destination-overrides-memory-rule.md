---
class: principle
date: 2026-05-26
source: learnings/skills/learn/2026-05-26_write-to-wk-skills-home.md
---

- **Rule:** Skill learnings are written to `$WK_SKILLS_HOME/learnings/skills/`, never `~/.claude/memory/`. This destination overrides any global "all memories go to ~/.claude/memory/" rule in CLAUDE.md or user instructions — skill learnings are skill-improvement artifacts consumed by `wk-sharpen`, not agent memory.
- **Why:** Agent followed a global memory rule and rerouted learnings to `~/.claude/memory/`, orphaning them from `wk-sharpen`'s batch-distillation scan and breaking the learning → sharpening loop.
- **Where:** Step 3 HARD RULE — "destination is `$WK_SKILLS_HOME/learnings/skills/`, never `~/.claude/memory/`."
