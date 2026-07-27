---
class: principle
---

# Ownership resolves before thoroughness; severity never grants it

**Rule** — MUST-FOLD (`severity: high`) governs *how thoroughly* to fold an item this
run already owns. It never decides *whether* the run owns it. Ownership is settled
first, by the concurrent-arrival test; severity cannot convert an unowned or
concurrently-claimed arrival into an assigned one. The escalation path for a
high-severity unclaimed item is to surface it to the dispatcher as priority backlog.

**Corollary** — an independently blocked commit gate is itself grounds to *defer* a
MUST-FOLD item, not to fold it harder. An unlandable fold entangles a shared tree
instead of protecting anything.

**Why** — the two rules were written on different axes: MUST-FOLD as an unconditional
obligation about an item, the arrival test as a condition about the tree. With no
stated precedence, `severity: high` reads as licence to override a concurrency hold —
which inverts the intent exactly. Read in the wrong order, the highest-severity items
become the ones an agent folds into a peer's in-flight edits, because severity is what
appears to authorize it. The two questions are sequential, and the ordering has to be
written down to be relied on.

**Where** — `SKILL.md` → *IMPORTANT — high-severity learnings are not optional*, stated
at the point MUST-FOLD is defined so the precedence is read with the obligation.
