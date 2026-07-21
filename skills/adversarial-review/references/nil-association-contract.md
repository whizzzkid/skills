---
class: principle
---

# Rule out a nil-association finding by tracing the contract, not by guarding (sweep 2.80)

**Rule** — When a subagent flags a nilable ActiveRecord association dereference,
grep the model for the `belongs_to` optionality and the parent's `dependent:`
strategy before accepting it. A required (non-`optional: true`) `belongs_to` plus
a parent `has_many … dependent: :restrict_with_exception`/`:restrict_with_error`
makes a persisted record with a nil/dangling association structurally unreachable.
Cap the finding at `question`, add no defensive guard. (Sweep 2.80.)

**Why** — Absence of a nil guard is not itself a defect (contract #8,
absence-claim-cautious). A required `belongs_to` + restrict-on-delete parent is an
enforced invariant; a guard for it documents an unreachable path. This is the
ActiveRecord-association instance of sweep 2.3's "trace the producer before
flagging a missing guard."

**Where** — `wk-adversarial-review` sweep catalog →
`references/sweep-catalog-extended.md` row 2.80.
