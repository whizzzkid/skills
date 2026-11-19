---
class: principle
---

# A user tick can contradict the owning system

**Rule** — At close, re-query the owning system for every user-ticked span, not only pending ones. Still
non-terminal (draft, unsubmitted) → keep the tick in the snapshot, add a one-line mismatch note to the snapshot and
the next page's notes, and never re-open the span unprompted.

**Why** — Cross-validation ran in one direction only: pending spans were checked for silent completion, ticked spans
were trusted outright. A tick records user intent; a saved draft is still owed, so an unchecked tick can hide open
work, while overriding it would discard the user's decision. The note surfaces the gap without taking either away.

**Where** — `SKILL.md` → `end` Stage 3 (*Cross-validate ticked spans too*);
[`missed-end-rollover.md`](missed-end-rollover.md) close checklist step 4.
