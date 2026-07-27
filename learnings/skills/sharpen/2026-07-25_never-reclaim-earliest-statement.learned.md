---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

A reachability fold turns the rule's own upstream statement into a reclaim candidate, and
deleting it recreates the defect one step earlier.

**What happened:** The fold's job was to make a control rule reachable from the first step
that prescribes it, by adding a pointer at that step. The byte budget then needed reclaim.
The single most attractive target — provably duplicated, zero apparent coverage risk — was
the same rule's pre-existing statement at an *earlier* step, which the new bullet now
appeared to supersede. Deleting it would have netted the bytes and passed every existing
check: it is genuinely duplicated text, it is not a gate's enumerated pass/fail list, and it
is not being relocated behind a pointer, so none of the recorded reclaim prohibitions fire.
It was rejected only because the run happened to notice that the surviving statement sits
*later* in reading order than the deleted one — which is precisely the defect class the fold
existed to fix. Confirmed against the source by reading the step ordering directly.

**Root cause:** The reclaim rules protect content by *kind* (gate checks, verification
checklists, load-bearing commands) and by *destination* (never behind a pointer). None of
them protect content by *position*. A duplicate-detection pass is order-blind: it sees two
statements of one rule and scores the redundancy, with nothing scoring which occurrence a
run reaches first. For a fold whose whole purpose is reachability, the ceiling pressure and
the fold's intent point in exactly opposite directions, and the byte hunt argues persuasively
for undoing the fix.

**Suggested fix:** Add a positional constraint to the reclaim rules: when two statements of
one rule exist, reclaim may delete only the *later* one — never the earliest statement, which
is the one that actually guards. State it where the duplicate-search order is prescribed, so
it is read at the moment a candidate is being scored rather than after the cut. Generalize
beyond the byte budget: any de-bloat merge of duplicated rules should keep the occurrence a
run reaches first and cross-reference forward, not backward.
