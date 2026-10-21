---
class: principle
---

**Rule:** When rollover closes the previous workday, launch one agent fleet for both the nested `end` and today's
`start`, with explicit per-part window bounds (A open now / B closed-day evidence / C carry-over status). Date a
carry-over's completion from its owning system's timestamp, never from the page it was toggled on.

**Why:** Both flows gather the same evidence window; separate launches double the fleet for no new evidence. A page's
date reflects when the box was toggled, not when the work finished, so it can attribute an outcome to the wrong day.

**Where:** `SKILL.md` start Stage 0.5; `references/missed-end-rollover.md` "Shared gather"; sibling `README.md`.
