---
class: principle
---

# Reading order objects to the pointer's position, not the content's

**Rule** — A relocation moves a rule later in reading order **only if** the surviving
pointer sits later. Write the pointer into the bullet the block was cut from and the rule
stays reachable at exactly the position it occupied — the reading-order objection dissolves.
Before recording a reclaim pool as exhausted, or the >=1.2x planning ratio as unreachable,
re-test every target rejected on reading order under a cut-site pointer. Reserve the
protection for content that cannot be pointed at from its own position (a gate's enumerated
pass/fail checks, a verification checklist).

**Why** — The protection was stated as a property of the *candidate* ("its full statement is
reachable only via a pointer appearing later in the body"), which reads as a fixed attribute
to test and reject on. Nothing said the pointer's position is a free variable the author
controls, so the objection became a verdict on the target rather than a constraint on the
edit's shape. Compounding it, recorded rejection notes preserved the verdict but not its
dependence on pointer placement, so each later pass re-inherited the conclusion without the
escape hatch. Two prior passes declared the pool exhausted and fell back to tightening the
addition; one recorded the ratio as unreachable at 1.15x.

**Verified against source** — Confirmed before drafting, not taken from the report:

- Both statements of the objection key on the content
  (Step 7.5 de-bloat HARD RULE; size-ceiling reclaim search order). Neither names pointer
  placement as controllable.
- The skill body already *practises* cut-site pointers throughout — inline imperative plus
  a `references/…` pointer in the same bullet — so the exempting shape was in use while the
  rule forbidding it stayed unqualified. The gap is in the rule's framing, not the practice.
- The two recorded rejections were re-read: one rejects on coverage (unproven duplication),
  the other purely on reading order. Only the second is unlocked by this principle.

**Classification** — `principle`. Generalizes to any ceiling-bound file whose reclaim pool
is scored by reading order.

**Escalation** — None. This corrects an existing rule's framing rather than repeating it; no
rule failed that was correctly stated.

**Executed, not just adopted** — The rejected design was driven against the artifact this
pass: a 224 B relocation with the pointer written at the cut site, reclaimed from a target
both prior passes walked past. Reading order verified unchanged (the pointer occupies the
cut bullet); coverage verified by landing the moved text in a *linked* reference. The two
stale rejection notes were rewritten to what now holds.

**Arithmetic for this fold** — Addition 280 B (remedy clause 99 B; re-test bullet 181 B).
Measured audit allowance 0 B — every cleanup item lands in `references/`, outside the
ceiling-bound file. Reclaim 386 B across three targets, two of them cut-site relocations
(matcher rationale 224 B, throwaway-index procedure 93 B, signing-capability rationale
69 B). Net **-106 B**; body 24515 -> 24409 against the 24576 B ceiling. Ratio 1.38x, so the
planning target was met rather than waived — the headroom that read as 61 B was never the
constraint.

**Where** — `SKILL.md` -> Step 7.5 de-bloat HARD RULE (relocation exemption) and the
size-ceiling reclaim search order (re-test rejected targets).
