---
class: principle
source: learnings/skills/sitrep/2026-10-26_scorecard-length-newline-patch.learned.md
date: 2026-10-26
skill: wk-sitrep
---

**Rule** — Two additions to `start`:

- **Interview blocks:** state the scorecard default as 45 min (a user-stated length wins) and render a created block
  as done only after the calendar skill's post-create re-list confirms duration and zero overlap; a failed check
  renders as a warn item.
- **Multi-line patches:** put the newline in a variable first (`nl=$'\n'`) and substitute the variable; afterwards
  grep the page for stray literal `\n` text and assert every item ID is unique and on its own line.

**Why** — Stage 2c hard-coded a 30-min scorecard and trusted the create call, so a short, overlapping block rendered
as done. Separately, an inline ANSI-C newline inside a double-quoted parameter substitution was written as literal
characters, fusing three spans onto one line. Verified: zsh 5.9 keeps `$'\n'` literal in that position while bash
expands it; a variable-held newline works in both.

**Cross-skill** — The calendar-side mechanics (busy definition, 15-min scan, post-create verify HARD RULE) live in
`wk-cal` (landed with the calendar-owned learning on the same incident). The shell trap itself is recorded in
`wk-workstyle-shell` → `zsh-bash-portability.md`, its portability home.

**Where** — `SKILL.md` → `start` Stage 2c; Stage 4 → *Multi-line patch → newline in a variable*;
`wk-workstyle-shell` `SKILL.md` portability bullet + `references/zsh-bash-portability.md`.
