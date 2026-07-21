---
skill: wk-adversarial-review
date: 2026-07-21
type: pattern
severity: low
---

Rule out a "nil association" finding by tracing the association contract, not by adding a defensive guard.

**What happened:** A fresh adversarial subagent flagged a serializer that dereferences `record.parent` as a possible nil-dereference blocker. Instead of reflexively adding a nil guard, the chain was traced: the child declared a required `belongs_to :parent` (non-optional) and the parent declared `has_many :children, dependent: :restrict_with_exception`. Together these make a persisted child with a nil/dangling parent structurally unreachable, so the finding was downgraded to non-issue and no defensive code was added.

**Root cause:** Absence of a nil guard is not itself a defect (contract #8 / absence-claim-cautious). A required `belongs_to` plus a restrict-on-delete parent is an enforced invariant; a guard for it documents an unreachable path.

**Suggested fix:** When a subagent flags a nilable-association dereference, before accepting it grep the model for the `belongs_to` optionality and the parent's `dependent:` strategy. A required belongs_to + `restrict_with_exception`/`restrict_with_error` parent → the nil path is unreachable; cap the finding at question and do not add a guard.
