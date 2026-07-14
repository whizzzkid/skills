---
skill: wk-sharpen
date: 2026-07-14
type: correction
severity: medium
---

A byte-reclaim cut that deletes a duplicated rule must delete it outright, not
replace it with a cross-reference — the reference re-spends most of the reclaim.

**What happened:** Folding a rule into a SKILL.md with 91 bytes of headroom, the
staged body came in 29 B over. The "one decisive cut" removed a duplicated
sentence (~68 B) but replaced it with a `(per Hard Rule 7)` parenthetical
(~50 B), netting only ~18 B — still 11 B over, forcing a second corrective
cycle (the re-violation signal the skill warns against).

**Root cause:** When a line is being removed *because it is provably duplicated
elsewhere*, any replacement cross-reference is itself redundant — the rule is
already stated at the cited location. Adding "per Hard Rule 7" restated the very
pointer that justified the deletion.

**Suggested fix:** In Step 7.5's reclaim guidance, state: when the reclaim target
is a duplicated rule, delete it with zero replacement text; a cross-reference is
only warranted when the removed content was NOT already covered elsewhere. Budget
the reclaim as the FULL byte count of the deleted line, not line-minus-pointer.
