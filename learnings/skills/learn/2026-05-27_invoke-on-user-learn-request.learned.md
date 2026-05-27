---
skill: wk-learn
date: 2026-05-27
type: gap
severity: medium
---

Invoke wk-learn immediately when user says "make a learning" — never write memory instead.

**What happened:** User asked to "make a learning" for a skill. Agent started writing a memory file to ~/.claude/memory/ before being corrected.

**Root cause:** No instruction in the skill (or CLAUDE.md at the time) that user-facing "make a learning" / "capture a learning" / "learn X for skill Y" phrases are trigger phrases for wk-learn. Agent defaulted to its general memory system.

**Suggested fix:** Add to wk-learn's trigger section: user phrases "make a learning", "capture a learning", "add a learning", "learn X for Y skill" are direct invocation signals. The skill must be invoked before any file is written, and output must go to $WK_SKILLS_HOME/learnings/skills/<skill>/, never to ~/.claude/memory/.
