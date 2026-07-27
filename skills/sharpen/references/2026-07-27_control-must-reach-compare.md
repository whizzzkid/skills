---
class: principle
source: learnings/skills/sharpen/2026-07-27_control-must-reach-compare.md
severity: medium
date: 2026-07-27
---

# Control must reach the compare, not merely target the disagreement

**Principle** — A control for a bug that lives in a *decision between two stages* must be
built so the decision is actually taken. Matching the data shape and targeting the right
disagreement both leave the decision reachable-but-unreached, and the resulting control is
dead while reading exactly like a clean result.

**Why the prior wording was insufficient** — The landed rule required the control to
"reproduce the *disagreement*, not the data shape permitting it". Two successive
constructions satisfied that wording in letter and were still dead:

1. **Mismatched sorts.** One stream sorted under the ambient locale, the other under the
   pinned locale, then compared under each locale in turn. Both arms mis-walked and returned
   the same wrong count — the arms agreed *in wrongness*, which reads exactly like a
   decorative pin.
2. **Correct sorts, wrong differing element.** Both streams sorted under the pinned locale,
   an order-flipping entry present identically on both sides, and the *differing* entry
   all-lowercase. The merge consumed the order-flipping pair at an equal-vs-equal step,
   advanced both streams with cursors still aligned, and reached the differing entry without
   ever mis-walking. Both arms returned the known truth.

**The live construction** — Both streams sorted under the pinned locale; the element that
**differs between the streams** is itself given the order-flipping form, and is placed on
whichever side feeds the arm under test. The pinned arm then returns the known truth while
the unpinned arm over-reports — the arms disagree, and the pin is proven load-bearing.

**Mechanism** — A merge comparison consults collation order only when it must decide *which
stream to advance*, which happens only at a pair where the two streams differ. An
order-flipping element appearing identically on both sides is consumed by the equality step
and never exercises the ordering assumption. So a control can carry the right data, target
the right disagreement, and still never execute the comparison under test.

**Why the existing tripwires miss it** — This is the same "dead control" family the skill
already warns about, but it presents as *agreement at the correct answer* rather than as a
zero. Neither the zero-based canary tripwire nor the "arms must differ" check catches the
misreading; reading arm agreement at the truth value as evidence the pin is decorative is the
natural wrong conclusion, and construction 2 above produced exactly that reading.

**Verification** — Verified by driving the comparison utility directly over all three
fixtures, not inferred.

**Where it landed** — `SKILL.md` → Batch Mode, as an in-place amendment of the
two-stage-disagreement sub-bullet under the "source drained" control rule. Amended in place
rather than added as a new bullet: the prior wording states the weaker test the two dead
controls satisfied, so leaving it alongside a stronger sibling would keep a rule that is
known to pass dead constructions.

**Byte arithmetic** — Step 5 audit run **before** the budget locked → measured cleanup
allowance **0 B**. Category-1 reclaim is corroborated exhausted: every remaining candidate
carries a recorded stay-inline or rejected-relocation note, so the hunt was not widened and
the *addition* was tightened instead. Old bullet **261 B**, new bullet **261 B**, net **0 B**;
body 24483 → 24483 B against a 24576 B ceiling (93 B headroom preserved). The ≥1.2× planning
ratio is undefined with zero reclaim; the binding gate (net non-positive AND under every
ceiling) is met. This record and the README narrative both land outside the ceiling-bound
file.

**Rejected** — Adding a second bullet alongside the existing one (**+312 B**, breaches the
93 B headroom) and any variant preserving the "reproduce the disagreement, not the data shape
permitting it" framing (**+51 B** at the tightest, still net-positive). No relocation was
proposed, so no new stay-inline note is warranted.
