---
class: principle
---

# A denylist is a pattern file, never a haystack

**Rule** — wherever a gate greps a subject against a denylist, name the direction at the
point of use: the subject is the *input*, the denylist supplies the *patterns* via `-f`
(`printf '%s\n' "$term" | command grep -qiEf .skillprohibit`). Draw the proving canary from
a pattern line that carries a **metacharacter**.

**Why** — "grep X against Y" does not fix which operand is the pattern source. Read with
the denylist on the receiving end, the gate becomes a fixed-string search for the subject
*inside the pattern file*. That degrades to matching only the denylist's metachar-free
lines and silently misses every regex one — and it returns rc=1 with a clean verdict, so
nothing in the run signals a problem. The failure is **open**, which is why the direction
cannot be left to inference.

The metachar requirement is the second half of the same mechanism. A canary expanded from a
metachar-free line matches under *both* readings — as a `-f` pattern, and as a literal
needle that genuinely appears in the pattern file — so it fires green while proving nothing
about direction. Only a metachar-bearing line separates them.

**Verified against source** — Confirmed before drafting, not inferred. `.skillprohibit`
declares `grep -iE` patterns in its own header; of its 14 active patterns, 5 are plain
literals and 9 carry metacharacters. Both directions were driven over the same file with a
canary built programmatically from a metachar-bearing line: the haystack reading returned
**no match** on a subject the pattern provably matches (dead-open), the `-f` reading fired.
A negative control (an unrelated token) stayed clean under both, and every needle was
length-guarded.

**Fixture variation** — the reproduction was re-run with the canary drawn from a plain-
literal pattern line instead. There the haystack reading **matches**, so the misreading is
*selectively* live rather than uniformly dead. That sharpens the reported mechanism: a run
that happens to canary-test with a metachar-free line gets a green canary over a gate that
is still blind to two thirds of the list. The fold was re-derived from that sharpened
mechanism rather than from the report's wording, per the Step 1 disproof rule.

**Classification** — `principle`, `partial`. The direction was already unambiguous *by
example* in the Step 5 scan and in [`staged-path-scan.md`](staged-path-scan.md)
(`| command grep -iEf`, `printf … | grep -f`), but never stated as a rule, and the Step 3
bullet — written later and read first — used the ambiguous "against". An example is not a
rule when the two gates over the same file are specified at different precision.

**Escalation** — None. This is a missing direction in an existing guard, not a repeat of a
rule that already covered the case. Positive-steering evidence also blocks it: the source
learning concedes the skill's own mandated canary is what caught the inversion, so the
canary rule fired correctly and spends no notch. The fix removes the ambiguity at the point
of use instead of hardening the net that caught it.

**Gate governing this fold's own landing** — the Step 3 prohibited-subject gate. Applied the
**post-edit** (stricter) text: subject on stdin, patterns via `-f`, with the canary drawn
from a metachar-bearing line. Subject scan returned clean under a canary proven live.

**Rejected** — Nothing relaxed. Did not weaken or relocate the canary bullet to buy bytes;
it is the gate's only tripwire against the open failure. Did not touch the Step 5
`**CRITICAL**` hook-vs-hand-roll bullet's lead formulation — [`2026-07-25_same-flags-not-same-engine.md`](2026-07-25_same-flags-not-same-engine.md)
records that the engine-shadowing framing leads by deliberate decision, and cutting it would
undo that fold's intent.

**Rejected reclaim targets (do not re-propose)** — The ticket-shape row and the staged-path
hand-roll row: [`overfit-categories.md`](overfit-categories.md) records their inline
placement as deliberate ("procedure, not a checklist"), and that ground still holds. The four
inline size ceilings and the inline phased-approval clause carry prior stay-inline notes whose
grounds also still hold. Every remaining pointer-bearing line was scored **individually**
this pass, not dismissed on the prior record's aggregate "pool exhausted" note: lines 64, 99,
131, 138, 159, 172, 186, 240, 243, 260 and 276 are imperative-plus-pointer with no relocatable
rationale, so the category-1 pool is exhausted on per-candidate grounds.

**Arithmetic for this fold** — Baseline staged body **24466 B** / 24576 ceiling → 110 B
headroom, so the up-front reclaim regime triggered. Addition **+147 B** (new direction bullet
139 B; `denylist` → `metachar-bearing` on the canary bullet +8 B; `against` → `through` net
0 B). In-`SKILL.md` audit cleanup **0 B** — measured by running the Step 5 audit before the
budget locked, not reserved: every cleanup item lands outside the ceiling-bound file (this
record, [`prohibited-subject-gate.md`](prohibited-subject-gate.md),
[`staged-path-scan.md`](staged-path-scan.md), the sibling README `Version:` line). Reclaim
**−161 B** across two category-1 duplicates, each an inline rationale clause whose *linked*
reference states it in full and whose pointer already sits in the same bullet, so nothing
moves later in reading order:

- The drift-check recount bullet's failure-mode parenthetical (**−100 B**) —
  [`recount-probe-bounds.md`](recount-probe-bounds.md) states all three failure modes in
  full under *Both directions are probe defects* and *A passing member control cannot
  distinguish the two*. Every imperative in the bullet survives inline.
- The drained-verdict bullet's "a traversal skipping a class of node returns a dead zero"
  (**−61 B**) — [`batch-mode-sources.md`](batch-mode-sources.md) states it in full, with the
  `find -type f` / symlinked-directory instance the inline clause had abstracted away.

Net **−14 B**; body 24466 → 24452 against the 24576 ceiling, leaving 124 B. Ratio 161/147 =
1.10×, under the 1.2× planning target — the hunt was entered and exhausted per-candidate, so
the *addition* was tightened instead (the mechanism behind "fails open" moved to the
already-linked [`staged-path-scan.md`](staged-path-scan.md), where the canary rule that
depends on it lives). Front-matter 1003/8192, `description:` 466/1024, `allowed-tools:` 8/36.

**Where** — `SKILL.md` → Step 3 → *HARD RULE: prohibited-subject gate*; full direction and
canary mechanics in [`staged-path-scan.md`](staged-path-scan.md), gate statement in
[`prohibited-subject-gate.md`](prohibited-subject-gate.md).
