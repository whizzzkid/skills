---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

MUST-FOLD (`severity: high`) and the concurrent-arrival ownership rule state no precedence, so the severity flag reads as authority to fold into files another run is actively editing.

**What happened:** A batch run opened with three sources drained and one unprocessed
learning whose target skill already carried an uncommitted, version-bumped fold. Mid-run a
second learning materialized in the same target's inbox dir with `severity: high` and an
mtime postdating the run's start, while the tree showed a live concurrent writer (tracked
files modified after the last commit, one touched at the run's start second). Two rules in
the skill body then pointed opposite ways: the high-severity block says such an item is
MUST-FOLD and "reference-file-only routing is forbidden", while batch-mode Source 2 says an
arrival postdating the run's start is "unowned, not assigned → report as unclaimed backlog
and do not fold". The run folded nothing and reported both items as unclaimed.

**Root cause:** The skill never says which of the two rules is scoped to what. MUST-FOLD is
written as an unconditional obligation about an item, and Source 2 as a condition about the
tree, so nothing on the page rules out reading a `high` severity as licence to override the
concurrency hold. The two questions are actually sequential — *do I own this item* is
decided before *how thoroughly must I fold it* — but that ordering is implicit. Read in the
wrong order, the highest-severity items become exactly the ones an agent will fold into a
peer's in-flight edits, since severity is what appears to authorize it. A blocked commit
gate compounds it: with signing down the fold cannot land at all, so folding only adds a
third uncommittable fold and collapses the path-scoped index separation prior runs set up.

**Suggested fix:** State the precedence explicitly where MUST-FOLD is defined: ownership is
resolved first, and MUST-FOLD governs the thoroughness of a fold this run owns, never
whether it owns it. Severity never converts an unowned or claimed arrival into an assigned
one; the escalation path for a high-severity unclaimed item is to surface it to the
dispatcher as priority backlog, not to fold it. Add the corollary that an independently
blocked commit gate is itself grounds to defer a MUST-FOLD item rather than fold harder,
since an unlandable fold entangles a shared tree instead of protecting anything.
