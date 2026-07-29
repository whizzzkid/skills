---
class: principle
---

**Rule**

A recorded failure claim names the environment it was observed in — "fails on
`<env>` with `<symptom>`; unverified elsewhere". A single-environment observation
never earns the declarative universal voice ("is broken", "cannot pass"), and never
drives config — excluding a check from required gates, relaxing acceptance criteria —
until a second environment agrees.

**Why**

Nothing in the doc flow forced the observation's scope to be stated, so a local
browser/tooling version pairing got written as a property of the check itself. The
check passed on its first run elsewhere, and the doc, the acceptance criteria, and the
protection config all had to be reversed.

Reversing it exposed a second gap: the first correction pass fixed the verdict sentence
but left phrasing the verdict had justified in two other spots. The leaked phrases
shared no term with the edited sentence — the only term tying them together was the
*subject's* identifier, not the retracted wording. Recorded as one escalation notch on
the cross-section-consistency rule (rung 1 → 2, `**Important:**`), plus the sweep-by-
identifier sub-rule that makes the notch actionable. See
[`cross-section-consistency.md`](cross-section-consistency.md).

**Where**

`skills/docs/SKILL.md` → Claim-Grounding Gate (failure-claim bullet); Step 4 spec
quality gate (cross-section consistency).
