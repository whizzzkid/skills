---
skill: wk-workflow
date: 2026-08-17
type: correction
severity: medium
verified-against-source: yes
---

Brief parallel agents with actual design-token names, not assumed ones

**What happened:** Coordinator briefed 3 parallel agents with CSS breakpoint token
names `--bp-md` / `--bp-lg` that do not exist in the target repo. The actual tokens
are `--breakpoint-tablet: 640px` / `--breakpoint-desktop: 1024px`. One agent caught
the mismatch and used the correct values; the others would have written broken CSS
if they hadn't read the stylesheet themselves.

**Root cause:** Coordinator assumed token naming from memory instead of reading the
actual CSS custom properties before drafting agent prompts.

**Suggested fix:** When briefing parallel agents on CSS/design-token work, always
include the exact token names and values by reading the stylesheet first. Never
assume token names from convention — read `application.css` (or equivalent) and
quote the actual declarations in the agent prompt.
