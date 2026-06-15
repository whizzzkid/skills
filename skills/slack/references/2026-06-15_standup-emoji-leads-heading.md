---
class: principle
date: 2026-06-15
---

# Standup headings lead with the emoji; Blockers is always present

**Rule:** In the standup snippet, the day-marker emoji is the **first** character
of each heading — `👈🏽 Yesterday`, `👉🏽 Today`, `✋🏽 Blockers` — never trailing
(`Yesterday 👈🏽` is wrong). Blockers is always rendered with its `✋🏽`; emit a
single `None` child when there are none, rather than omitting the section.

**Why:** A prior "emoji is mandatory / lead character" phrasing did not steer —
the generated snippet trailed the emojis and dropped the Blockers emoji entirely,
so the rule was escalated (bold) and made explicit with a wrong/right example. The
earlier omit-when-empty rule for Blockers was superseded: the user wants the
section always visible.

**Where:** wk-slack §Standup Snippet (owner); reinforced in wk-sitrep Stage 4
standup bullets + plaintext-fallback.
