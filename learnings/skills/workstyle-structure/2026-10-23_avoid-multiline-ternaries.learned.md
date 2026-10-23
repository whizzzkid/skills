---
skill: wk-workstyle-structure
date: 2026-10-23
type: correction
severity: low
verified-against-source: n/a
---

User rejected multi-line and inline ternaries in new code as hard to read.

**What happened:** New path-resolution code chose a base directory with a multi-line ternary and a folder name with an
inline ternary inside a call argument. The user asked for it to be simplified.

**Root cause:** The structure rule bans only nested ternaries; the agent treated non-nested ternaries as always fine,
including multi-line ones and ones embedded in arguments.

**Suggested fix:** Extend the conditionals rule: prefer a default value plus a plain `if` override over a ternary that
spans lines or sits inside a call argument, even for a two-way choice.
