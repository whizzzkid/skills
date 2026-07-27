---
class: principle
skill: wk-sharpen
date: 2026-07-26
severity: medium
---

# The landing needle comes from the learning's subject, never from a supplied location

**Rule** — A landing check derives its needle from the source learning's own distinctive
subject term and discovers the location by matching. A caller-supplied slug→line map is an
unverified hint under the report-is-a-hypothesis rule, never an index. Per-line novelty is
necessary but not sufficient: it corroborates that a fold touched a region and certifies
nothing about *which* lesson landed there. Print each match beside its slug — a bare rc
cannot show a mis-attribution. A map that disagrees with where the subject actually matches
is a stale-map signal to report, not a location to chase.

**Why** — The existing landing rule fixed *which copy* to read (worktree bytes, not installed
or a tool's rendering) but left the needle's *provenance* unconstrained. In a fold that
rewrites a contiguous span, every line is new, so a line-keyed check is near-tautological: it
returns FOLDED for any line in the span regardless of content. The two propositions —
"this line is new" and "this principle landed" — are independent, and only the second is the
question being asked.

**Verified against source** — The mechanism was reproduced, not taken from the report:

- Subject-keyed sweep over the nine folded slugs: each subject term PRESENT in worktree /
  ABSENT at HEAD, with a control cut from a region the fold did not touch matching on *both*
  sides — proving the HEAD-side grep fires, so each rc=1 is a real absence.
- The supplied map was confirmed scrambled: the subject attributed to one slug matches at a
  line ~200 lines away, and the line the map named carries a different learning's principle.
- **Falsification.** A counterfactual copy was built in which exactly one principle never
  landed (that line reverted to its HEAD wording, line count held constant). The line-keyed
  check on the map's entry for that slug still scored **FOLDED**; the subject-keyed check on
  the same file correctly scored **NOT-LANDED**. The false positive is demonstrated, not
  asserted.

**Classification** — `principle`. Generalizes to any verification whose needle's location is
supplied by the same party whose claim is under test.

**Escalation** — None. The adjacent landing rule constrains the copy read, not the needle's
provenance; this is a genuine gap, not a re-violation.

**Arithmetic for this fold** — Baseline body 24561 B, 15 B slack. Addition +220 B. Measured
audit-cleanup allowance **0 B** — the Step 5 audit ran before the budget locked and found no
cleanup landing inside the ceiling-bound file (the README `Version:` bump carries no ceiling).
Reclaim −298 B across four targets, each verified verbatim-present and stated in full by an
**already-linked** reference: improve-mode phase teaser −77, bare-`grep` routing rationale
−60 (staged-path-scan), unreachable-ratio tail −123 (byte-budget), ceiling-bound-only
parenthetical −38 (byte-budget). Net **−78 B**; body 24561 → 24483, 93 B under ceiling.
Ratio 1.35× clears the 1.2× planning target.

**Defect caught by the measure** — The first staged measure read 24482 against a predicted
24483. Localizing the 1 B (rather than accepting it as rounding) exposed a real formatting
break: deleting a line's trailing clause had also consumed its newline, merging the
"Reclaim exhausted → tighten the addition" bullet into the preceding one and burying that
rule mid-line. Restoring the newline brought the measure to exactly 24483.

**Rejected reclaim target (do not re-propose)** — The reclaim-search-order cross-reference
("Never reclaim a rule's earliest statement", ~129 B) scores as a provable duplicate of the
de-bloat merge bullet, but `2026-07-25_never-reclaim-earliest-statement.md` records it as a
**deliberate forward cross-reference**, budgeted as such at the point of use. Deleting it
would undo a recorded placement decision, not remove accidental duplication.

**Where** — `SKILL.md` → Step 3 → *HARD RULE: re-violation escalation*, as a sub-bullet under
the landing-check clause.
