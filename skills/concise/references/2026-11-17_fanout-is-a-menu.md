---
class: principle
---

# Per-tool fan-out is a menu

**Rule** — under "one recommendation, not a menu", a per-tool / per-platform fan-out (one block per package
manager, OS, or CI vendor) counts as a menu. Unknown stack → show the likely one and name the swap in one line.
"Pick one", "also consider", and unordered root-cause lists are menus too. Pre-send check: every actionable item
after the first opens with its trigger condition.

**Why** — the weekly eval's `ladder` probe fell from 8/10 to 5/10 with the rule loaded. Failing replies did lead
with one fix, then broke it into parallel per-tool variants, or added a "pick one" or "also consider" list. The
rule's wording ("never parallel options") did not make those shapes read as violations. Escalation was by
clarifying what counts as a menu, not by a louder label.

**Where** — `SKILL.md` → HARD RULES — answer shape → *one recommendation, not a menu* (sub-bullets).
