---
class: principle
---

**Rule:** Run any repo-local automated-review/static-analysis tool as an
explicit numbered sweep in the pre-push gate, before the adversarial subagent.
Gate the verdict on a clean run; fold its blockers/majors.

**Why:** A pre-push check that lives only in an ambient memory note ("run X
before every push") competes with context pressure and gets silently skipped
under load — review findings the tool would have caught locally then land
post-push. Memory facts are loaded per-session but are not guaranteed to fire;
a procedure step always executes. The fix is placement, not emphasis: move the
obligation from memory into the skill body as a step.

**Where:** wk-adversarial-review Step 2 intro (new bullet). Phrased
tool-agnostically — names no specific binary, so it generalizes to whatever
local review/lint tool a repo ships.
