---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

Step 7.5's binding gate ("net non-positive AND under every ceiling") and
`references/byte-budget.md`'s headroom-conditional reclaim rule disagree about whether a
content-adding fold may land when headroom is ample and the reclaim pool is empty.

**What happened:** A fold added ~900 B to a skill whose staged body measured 22076 / 24576
— headroom 2500, comfortably above the "~2× the edit" threshold that triggers a budgeted
reclaim hunt. Under `byte-budget.md` that fold needs no reclaim at all. Under the SKILL.md
sentence "Binding gate = net non-positive AND under every ceiling", it can never land: net
is +909 and no reclaim exists to offset it. The reclaim pool really was empty — the target
had zero inline `references/…` pointers (category 1), no scaffolding or dead labels
(category 2), and category 3/4 would have meant relocating load-bearing trap rules or
prose-mangling. The run had to pick a reading with nothing in the text to arbitrate.

**Root cause:** The two statements are scoped differently and neither says so. In
`byte-budget.md` the "binding gate" sentence sits inside the discussion of the ≥1.2×
*ratio* — it is telling a run that has already entered a reclaim hunt when to stop, not
telling every fold it must break even. SKILL.md lifts the sentence out of that context and
states it as the unconditional gate, where it reads as "no fold may ever grow a skill".
Read literally it also contradicts the same file's own escape hatch — "the ceiling never
outranks a load-bearing rule" — since an empty pool would force either a load-bearing cut
or an abandoned fold.

**Suggested fix:** Scope the gate sentence in SKILL.md to the case that produced it —
"**Once a reclaim hunt is in play**, the binding gate is net non-positive AND under every
ceiling; the 1.2× ratio is the planning target." Then state the ample-headroom case
explicitly, since it is the common one: headroom ≥ ~2× the edit and every ceiling clear →
report the arithmetic and land the fold; no reclaim is owed. Add the corollary that an
exhausted pool under ample headroom is a *stop*, not an escalation to prose-mangling —
the existing "ceiling never outranks a load-bearing rule" line already implies it but is
never connected to the gate.
