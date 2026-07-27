---
class: principle
---

# A control for a two-stage disagreement must reproduce the disagreement

**Rule** — When the bug under test is a *disagreement between two stages*, the positive
control must reproduce the disagreement itself, not merely the data shape that permits it.
Its two arms must **differ**; arms that agree mean the control never exercised the bug, and
its verdict is void until rebuilt. For the memory-marker diff specifically: mixed case is
necessary but not sufficient — order the listing and the marker under *different* collations
(or let the comparison's locale differ from the sorts') and assert a known truth value.

**Why** — The landed collation rule prescribed the control by data shape ("must carry a
mixed-case entry"). That prescription is necessary-not-sufficient, and a run obeying it
literally builds a control that proves the opposite of what it was built to show.

Reproduced directly before drafting, with mixed-case entries whose `C` and `en_US.UTF-8`
orders genuinely differ:

- Both streams sorted alike, comparison pinned `LC_ALL=C` vs ambient → **identical results**.
  `comm` emits the correct row set whenever each stream is walked under the collation it was
  sorted in, so one locale applied uniformly to both sorts *and* the comparison is
  self-consistent whichever locale it is. The two arms agree, and taken at face value that
  reads as evidence the pinning is decorative.
- Listing sorted `en_US.UTF-8`, marker sorted `C`, compared under `LC_ALL=C` → a **fabricated
  backlog row against a truth of zero**, and an inflated count against a truth of one. This
  is the only construction that discriminates.

So the load-bearing requirement is **uniform pinning across both sorts and the comparison** —
not the presence of mixed case, which only makes the disagreement expressible.

The failure evades the existing tripwire. The skill already warns that a control returning
zero is dead, but this dead control returns a **non-empty, correct-looking backlog identically
in both arms**. Nothing about it reads as empty or red, so a zero-based check never fires; the
only signal is that the arms fail to diverge.

**Classification** — `partial` → `principle`. The inline rule generalizes past collation to any
two-stage disagreement (encoding vs decoding, writer shape vs reader shape, sort vs compare);
the collation mechanics stay in the linked `memory-marker-diff.md`.

**Escalation** — None. No rule fired and failed: the existing prescription was newly landed and
under-specified rather than violated, and the zero-based control tripwire is not a re-violation
because agreement is outside the class of result it inspects. Baseline for this judgement is the
**worktree** (the fold being extended is uncommitted there); the installed copy is ahead of
`HEAD` and neither carries the corrected prescription, so no shipped rule could have steered the
reporting run.

**Rejected reclaim targets (do not re-propose)** — No relocation proposed; the category-1 pool
(an inline rule ending in a `references/…` pointer) remains exhausted per the prior fold's
record. A duplicate-phrase scan surfaced the "a rule's earliest statement" rule at two sites;
that second site is a **deliberate forward cross-reference** placed by the fold that added the
positional constraint, so cutting it would undo that fold's intent. Not a reclaim target.

**Arithmetic for this fold** — Addition **+261 B** (one sub-bullet at the batch-mode control
rule). In-`SKILL.md` audit cleanup **0 B** — measured rather than reserved: every cleanup item
this run found lands outside `SKILL.md` (this record, the sibling collation record's stale
clause, the linked reference's prescription, the README version line). Reclaim **0 B**. Net
**+261 B**; body 24202 → 24463 B against the 24576 B ceiling, leaving 113 B; front-matter
1003/8192, `description:` 466/1024, `allowed-tools:` 8/36. The up-front reclaim regime triggered
(headroom 374 B under 2× the fold) and its 1.2× target was **unreachable at zero coverage risk**;
per the binding-gate rule the arithmetic is reported rather than the hunt widened into
load-bearing content — net is positive, not non-positive, and every ceiling stays clear.

**Where** — `SKILL.md` → Batch Mode → Source 2, as a sub-bullet of the "source drained" control
rule; collation mechanics and the disagreement construction in
`references/memory-marker-diff.md`.
