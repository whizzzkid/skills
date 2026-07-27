---
class: principle
---

# A gate names what blocks — a conditional discipline is not a gate

**Principle** — Name as "the binding gate" only the condition that actually fails the
commit. A discipline the run *owes itself* under some trigger is a target, and restating it
flatly turns it into a universal rule no compliant run can satisfy.

**What the source showed** — The owning artifact (`check-skill-size.sh`) tests four size
ceilings and nothing else; "net non-positive" appears nowhere in it. So the blocking
condition is the ceilings, and net-non-positive is a reclaim discipline that the skill's own
headroom trigger already scopes ("headroom under ~2× the edit → budget reclaim targets").

**The contradiction** — One bullet made the reclaim hunt conditional on headroom; a bullet
three lines later stated "Binding gate = net non-positive AND under every ceiling" flatly.
Under ample headroom with an empty reclaim pool the two are jointly unsatisfiable: no
content-adding fold can ever land, since the only ways to reach a non-positive net are a
load-bearing cut (forbidden by the same file's "the ceiling never outranks a load-bearing
rule") or abandoning the fold. A rule that cannot be satisfied gets silently ignored, which
is strictly worse than a scoped one.

**Report claim corrected against the source** — The learning attributed the defect to
`SKILL.md` "lifting the sentence out of context" from a reference that scoped it. Reading
the reference disproved that: it stated the gate just as flatly, and only the *following*
sentence supplied scope. The contradiction lived in both files, so the fold corrected both
rather than re-aligning one to the other. Per the Step 1 hypothesis rule, the draft was
re-derived from the hook's semantics instead of from the reported mechanism.

**Not a relaxation** — Scoping the discipline preserves every anti-accretion property: the
hook ceilings still block, and the reclaim hunt still fires under tight headroom. Only the
unsatisfiable universal reading is removed.

**Generalized** — State a threshold's trigger in the same breath as the threshold. A
conditional restated one bullet from its own trigger reads as universal, and the pair then
contradicts itself with nothing in the text to arbitrate.

**Rejected (do not re-propose)** — Did not relocate the inline four-ceiling enumeration
behind its pointer to buy bytes: those are a gate's enumerated pass/fail checks, which the
skill forbids moving. Reclaim came instead from a failure-mode clause sitting under an
already-present pointer, relocated (not deleted) into the linked reference so coverage is
unchanged.

**Arithmetic** — Addition +43 B; reclaim −83 B (the `git reset` failure-mode clause moved to
the linked reference, pointer already at the cut site); measured Step 5 cleanup 0 B inside
the ceiling-bound file; net **−40 B**, body 24369 / 24576, ratio 1.93×.

**Where** — `SKILL.md` → Step 7.5 byte-budget bullets; `references/byte-budget.md` →
binding-gate section and the partitioned-index rule.
