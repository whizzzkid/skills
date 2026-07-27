---
class: principle
---

# Drift-check recount — prove the probe fires, and shape it to the source

**Rule** — a recount is evidence only once the counting probe is shaped to the
source's actual list markup (numbered vs bulleted vs table rows vs headings) *and*
shown to fire on a known-present member. Treat an unproven count — a zero above
all — as unverified, never as a drift finding.

**Why** — the failure is silent and bidirectional. A bullet-shaped probe scored a
numbered source `0` while the documented count was correct; that zero is
indistinguishable from real drift and invites "correcting" an accurate claim into
an inaccurate one. A probe matching the wrong construct can equally return a
plausible-but-wrong non-zero that hides real drift. Either way the number ships
with the authority of a measurement.

**Where** — `SKILL.md` → Step 7 → *Drift check* → the recount bullet.

## Scope generalization, not a new idea

The skill already held "a hand-rolled zero is unverified until the probe is proven
to fire", but only at the prohibited-subject gate and the staged-path scan. The
Drift-check recount stated *where* a count must come from ("recount from source,
never increment") and nothing about whether the probe could return non-zero at all.
The fold extends the existing guard's scope to the recount rather than inventing a
rule.

## Reproduced before drafting

Bullet probe against the numbered ladder returned `0`; a numbered probe returned
`8`, matching the documented "8-rung" claim. The claim was right and the probe was
the wrong shape.

## Confirmed live on this run's own drift check

Recounting the skill's documented sets with shape-matched probes plus a
positive control per probe: ladder `8`, overfit categories `9`, terminal-gate items
`5` — all matching. A heading-shaped probe for "4 sources" returned `3`, because
two sources share one heading; the documented `4` was correct. Had the heading
count been trusted, the pass would have manufactured drift and edited a correct
claim. A second control (`### ` against a purely numbered source) returned `0` with
a dead control, demonstrating the probe-dead signal the rule keys on.

**Rejected** — did not hoist the guard into a single general rule stated once. The
recount reader is at Step 7 and the existing scoped statements are at Step 3 and
Step 5; a forward cross-reference splits one check across three sections for no
byte saving. Stated at the point of use instead.

## Byte arithmetic

Ceiling-bound body was 22 B clear and the reclaim pool was exhausted (six recorded
stay-inline / rejected-relocation notes). Paid for the addition by tightening
matcher-rationale prose in the same file — no rule, error code, or failure mode
dropped — and by broadening the recount bullet in place instead of adding one.
Addition and payment measured separately, staged together, measured once with the
size hook's `measure()` verbatim through a throwaway index copy: body 24554 →
24554, net 0.
