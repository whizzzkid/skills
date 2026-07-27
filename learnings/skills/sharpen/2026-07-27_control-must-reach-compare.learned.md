---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A control aimed at a merge-comparison bug can satisfy the "reproduce the *disagreement*"
rule in letter and still be dead — the differing element must be the one whose ordering
flips, or the merge only ever walks equal pairs and never reaches the defect.

**What happened:** A landing check needed to certify that pinning collation on the
comparison stage (not only on the sorts) was load-bearing before trusting a zero from the
marker diff. The existing rule already says a two-stage-disagreement bug needs a control
that reproduces the disagreement, not merely the data shape permitting it. Two successive
controls were built against that rule and both returned agreeing arms:

1. **Mismatched sorts.** One stream sorted under the ambient locale, the other under the
   pinned locale, then compared under each locale in turn. Both arms mis-walked, so both
   returned the same wrong count. The arms agreed *in wrongness* — which reads exactly like
   a decorative pin.
2. **Correct sorts, wrong differing element.** Both streams sorted under the pinned locale,
   with a mixed-case entry present on both sides and the *differing* entry all-lowercase.
   The merge compared the mixed-case pair only as an equal-vs-equal step, advanced both
   streams, and reached the differing entry with the cursors still aligned. No mis-walk
   occurred, so both arms returned the known truth.

The third construction worked: both streams sorted under the pinned locale, and the entry
that **differs between the streams** given the flipping-order form (uppercase-initial),
placed on the side that feeds the arm under test. The pinned arm then returned the known
truth and the unpinned arm over-reported by one — arms disagree, pin proven load-bearing.

**Root cause:** Verified by driving the comparison utility directly over all three fixtures,
not inferred. The existing rule constrains the control's *intent* (target the disagreement)
and the earlier rule it superseded constrained the control's *data shape* (carry a
mixed-case entry). Neither constrains the thing that actually decides whether the defect is
reached: a merge comparison only consults collation order when it must decide *which stream
to advance*, which happens only at a pair where the two streams differ. An order-flipping
entry that appears identically on both sides is consumed by an equality step and never
exercises the ordering assumption. So a control can carry the right data, target the right
disagreement, and still never execute the comparison under test.

This is the same "dead control" family the skill already warns about, but it presents as
*agreement at the correct answer* rather than as a zero — so neither the zero-based tripwire
nor the "arms must differ" check catches it. Reading arm agreement at the truth value as
evidence the pin is decorative is the natural and wrong conclusion; the second construction
above produced exactly that reading. Refines the sibling
`collation-control-must-disagree` learning, whose rule both dead controls satisfied.

**Suggested fix:** State the control requirement in terms of *reaching* the comparison, not
only of targeting the disagreement: the element that **differs between the two streams**
must itself be the one whose ordering flips, and it must sit on whichever side feeds the arm
being measured. Require the control to assert a known truth value and require the two arms
to differ; arms that agree — at the truth value or away from it — mean the defect was never
reached and the control must be rebuilt before any conclusion is drawn from the real run.
Generalize past collation: for any bug that lives in a *decision between two stages*, the
control must be constructed so the decision is actually taken, since matching data shape and
correct intent both leave the decision reachable-but-unreached.
