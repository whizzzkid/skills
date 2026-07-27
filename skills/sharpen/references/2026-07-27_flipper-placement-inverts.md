---
class: principle
source: learnings/skills/sharpen/2026-07-27_control-element-must-be-matched.md
severity: medium
date: 2026-07-27
---

# Order-flipper placement inverts with which stage is unpinned

**Principle** — In a two-stage control (produce ordered streams, then compare them), the
order-flipping element must sit where the *unpinned* stage actually makes its ordering
decision. That site inverts depending on which stage is unpinned, and the placement that is
live for one stage is provably dead for the other. A rule naming only one placement reads as
unconditional and steers the next author into the dead one.

**Report vs source** — The field report proposed a flat rule: the differing element must be a
**matched pair present on both sides**. Driving `comm -23` directly over every placement
sharpened that into a conditional, so the reported mechanism was re-derived rather than
transcribed (a matched pair is the *dead* placement when the comparison is the unpinned stage,
which is the case the immediately preceding fold had encoded).

| order-flipping element   | compare unpinned, inputs sorted alike | one input's sort unpinned |
| ------------------------ | ------------------------------------- | ------------------------- |
| matched pair, both sides | dead — consumed by the equality step  | live — phantom row        |
| differs between streams  | live — merge must pick a stream       | dead — verdict invariant  |

**Mechanism** — A merge consults collation only when it must decide *which stream to advance*,
which happens only at a differing pair; so an unpinned comparison is exercised only by a
differing element. An unpinned *sort*, by contrast, skews the two inputs against each other:
the merge meets a shared row at mismatched offsets, mis-advances past its partner, and emits a
row both sides contain. A row present on one side only is emitted as unique by any walk,
correctly ordered or not, so its verdict is invariant and cannot register either defect.

**Distinguishing check** — Liveness is the arms' *verdicts* diverging. Sort orders provably
differing is not liveness: "sorts differ but arms agree" means the element is mis-sited, not
that the pin is decorative. Confirm each surplus row is present in the other side before
reading it as a finding.

**Verification** — Verified, not inferred: the full placement × unpinned-stage matrix was
driven through the comparison utility, and each cell's verdict compared against the fixture's
known truth. The prior fold's claim that a matched pair "never exercises the ordering
assumption" reproduced only for an unpinned comparison, which is what made the conditional
visible.

**Classification** — `principle`. Generalizes to any control over a produce-then-compare
pipeline where either stage can be left unpinned.

**Escalation** — None. The landed rule was followed in letter and proved conditional, not
violated; this is a gap in the rule's generality, so the framing fix carries the change and no
notch is spent.

**Byte arithmetic** — Step 5 audit run **before** the budget locked → measured in-file cleanup
allowance **0 B** (this record, the mechanics table, and the README narrative all land outside
the ceiling-bound file). Pre-edit body **24517 B** against a 24576 B ceiling — **59 B**
headroom, far under 2× any faithful statement of the conditional, so the addition was tightened
rather than the reclaim hunt widened (two prior records corroborate category-1 and category-2
exhaustion). Sub-bullet **260 → 273 B (+13)**; reclaim **−15 B** by prose-tightening the parent
drained-verdict bullet ("a traversal that skips" → "skipping", "for any content when rooted" →
"for content rooted", "form, and corroborate" → "form, corroborate"), which drops no rule,
command, or failure mode and touches no rule's earliest statement. Net **−2 B**, body
**24515 B**. The ≥1.2× planning ratio is unreachable at this headroom; the binding gate — net
non-positive and every ceiling clear — is met.

**Rejected** — A fully enumerated inline conditional (**+130 B** at its tightest, **+286 B** as
first drafted) breaches the 59 B headroom; the two branches were routed to the linked mechanics
reference and the inline rule reduced to the operative test ("site the flipper where the
unpinned stage decides — placement inverts per stage"), which is self-applicable and forces the
lookup. Deleting the sub-bullet's "agreement is no zero" clause was rejected again for the
reason already on record: its full statement is reachable only through a pointer appearing later
in the body, so the cut would move the rule later in reading order.

**Where it landed** — `SKILL.md` → Batch Mode, in-place amendment of the two-stage-disagreement
sub-bullet (parent bullet tightened for the reclaim); placement matrix, matched-pair
precondition, and the sort-order-is-not-liveness check in
[`memory-marker-diff.md`](memory-marker-diff.md); README narrative rewritten to the conditional.
