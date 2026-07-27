---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

A positive control for the memory-marker collation bug must reproduce the collation
*disagreement*, not merely carry a mixed-case entry — a mixed-case control agrees
pinned-vs-unpinned and reads as proof the pinning is not load-bearing.

**What happened:** The Source 3 marker-diff guidance requires the positive control to
"carry a mixed-case entry so the control can actually exercise the ordering assumption."
Built exactly that way — listing `{Bravo.md, alpha.md}` vs marker `{alpha.md}` — the
control returned **1 row under `LC_ALL=C comm` and 1 row under ambient UTF-8 `comm`**.
The two arms agreed, so the control discriminated nothing. Taken at face value it is
evidence *against* the rule it was built to demonstrate.

**Root cause:** Verified by direct reproduction, not inferred. Mixed case is the
precondition for a collation difference, not the difference itself. The ambient and C
collations do order the same input differently (C: `Bravo.md alpha.md`; UTF-8:
`alpha.md Bravo.md`), but `comm` still emits the correct row set as long as **each
stream is walked under the collation it was sorted in** — a single locale applied
uniformly to both sorts and the comparison is self-consistent regardless of which
locale it is. The defect needs the two inputs to be ordered under *different*
collations, or the comparison's locale to differ from the sorts'. Driving that shape:
both sides holding the same two entries (truth = 0 unique-to-listing), listing sorted
under the ambient UTF-8 locale and marker sorted under C, compared with `LC_ALL=C
comm` → **1 fabricated backlog row**; both sides pinned to C → **0**. That is the
control that is alive.

Consequence: a run following the rule as written can build a mixed-case control, see
both arms agree, and conclude either that the pinning is decorative or that its own
harness is broken — when in fact the control was never capable of exercising the bug.
This is the "dead control" failure the skill already warns about, in a form that does
not present as a zero, so the existing zero-based tripwire does not catch it.

**Suggested fix:** State the control requirement in terms of the *disagreement* to be
detected, not the data shape that permits it: construct the control so the two inputs
are ordered under different collations (or so the comparison's locale differs from the
sorts'), assert a known truth value, and require the two arms to **differ** — a control
whose arms agree is dead and must be rebuilt before any conclusion is drawn from it.
Generalize beyond collation: for any bug that is a *disagreement between two stages*,
a control must reproduce the disagreement; matching the data shape that makes the
disagreement possible is not sufficient. Also drop the implication that a mixed-case
entry alone makes a control sound.
