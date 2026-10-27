---
skill: wk-sitrep
date: 2026-10-26
type: gap
severity: medium
verified-against-source: yes
---

Stage 2c hard-codes a 30-min scorecard and never verifies the created block; a multi-line in-place patch leaked a literal newline token.

**What happened:** The interview scorecard block was booked 30 min and overlapping another event, though 45 min was requested. Separately, patching three spans into the page via shell parameter substitution with an escaped-newline token inside double quotes wrote the literal characters instead of a newline, fusing spans onto one line.

**Root cause:** Stage 2c text says "30-min scorecard" and delegates slot choice to the calendar skill, which treats unanswered events as free and does not re-read the day after creating. For the patch, an ANSI-C quoted newline does not expand inside a double-quoted pattern or replacement.

**Suggested fix:** State the scorecard default as 45 min (user-stated length wins) and require a post-create re-list asserting duration and zero overlap before rendering the block as done. For multi-line patches, assign a real newline to a variable first, substitute with that variable, and grep the file afterward for stray literal token text and for unique, line-separated item IDs.
