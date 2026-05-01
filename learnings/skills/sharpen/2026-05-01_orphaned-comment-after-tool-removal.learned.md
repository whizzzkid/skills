---
skill: wk:sharpen
date: 2026-05-01
type: gap
severity: medium
---

Orphaned label comments remain after allowed-tool lines are removed

**What happened:** Removing a `Bash(mkdir -p:*)` allowed-tool line left behind its associated `# Learning capture (post-completion hook)` comment. The comment had no tool line after it and became dead text. Required three sweep passes (Phases A, B, C) to fully eliminate all instances across 27 skills.

**Root cause:** The orphaned-tool audit checked for tool lines but not for adjacent label comments that belong to the removed tool. The two are visually paired but structurally independent lines.

**Suggested fix:** Add a check to the improve-mode audit step: after removing any allowed-tool line, grep the same skill file for adjacent comment lines that labeled the removed tool. If found with no remaining tool line, remove the comment too.
