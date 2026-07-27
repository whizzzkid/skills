---
class: principle
---

# A control rule must be reachable from the first step that needs it

**Rule** — Every step prescribing a hand-rolled denylist match carries the canary-
construction pointer, not just the last one. Where two steps independently prescribe the
same hand-rolled match against the same regex-bearing list, state the construction rule at
the step reached **first** and cross-reference it from the later one.

**Why** — Reading order decides which rule fires. The prohibited-subject gate runs before
the staged-path scan, but the expand-the-pattern-to-a-literal rule was attached only to the
scan. A run therefore reached its first denylist grep, needed a positive control to prove
the zero, and built one by pasting a pattern line verbatim as the subject — a regex used as
literal text, which by construction cannot match itself. The control came back red and
printed a "matcher broken" verdict against a matcher that was fine. A rule that guards only
its second occurrence does not guard the first; the ordering guarantees the trap rather
than merely permitting it.

**Verified against source** — Confirmed before drafting, then reproduced:

- The gate's bullets name the denylist and the shape-matching hooks and stop there; the
  construction mechanics live in the reference linked only from the later scan.
- Driving the real denylist confirmed both halves: pattern source pasted as the subject
  returns no match, while a literal mechanically expanded from the same line fires.

**Classification** — `partial`. The construction rule itself was already covered in the
linked reference and in general form at the artifact-verification step; the newly distilled
part is pointer placement — reachability at the first prescribing step.

**Escalation** — None. The learning's own corroborating evidence blocks it: every other
zero-result check in the reporting run that carried its control inline was controlled
correctly on the first attempt, which isolates the failure to pointer placement rather than
to an operator skipping a known rule.

**Rejected suggestion (do not re-propose)** — Did not reclaim bytes by deleting the canary
clause from the artifact-verification step to make the new gate bullet its sole home. That
step is read *before* the gate, so moving the rule later would recreate this exact defect
one step earlier — the ceiling never outranks a load-bearing rule's reachability. Reclaim
came instead from three clauses whose linked references state them in full.

**Since generalized** — this one-off rejection is now a standing rule in the body: reclaim
may delete only the *later* duplicate, never a rule's earliest statement. Read the rule
there, not this note, when scoring a duplicate.

**Arithmetic for this fold** — Addition +194 B (gate bullet). Reclaim −258 B across three
inline clauses duplicated by their linked references: the Source 3 unanimous-verdict
direction rationale (−165), the staged-path-scan NONE clause now cross-referencing the gate
(−35), and the processed-state marker filename (−58). Net **−64 B**. The ≥1.2× planning
ratio against fold-plus-allowance was unreachable, but the binding gate — net non-positive
and every ceiling clear — is met, so the hunt stopped there rather than widening into
load-bearing content.

**Where** — `SKILL.md` → Step 3 prohibited-subject gate (canary pointer added); Step 5
staged-path scan (NONE clause now cross-references the gate). Construction mechanics remain
in [`staged-path-scan.md`](staged-path-scan.md).
