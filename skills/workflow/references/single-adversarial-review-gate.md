---
class: principle
---

# Adversarial review is one session gate, not a per-phase step

**Rule**

- Declare a session-level idempotent gate (e.g. `wk-adversarial-review`) at exactly one
  owning phase. Do not also list it as a separate run at later phases or "before every push."
- Express the "guard every push / PR transition" guarantee by pointing at the gate's
  idempotency contract — re-fire only on new commits since the last clear verdict, sweeping
  only the delta — never by instructing a fresh full re-run per step.

**Why**

- A gate that is documented at "Phase 4, 5, 6" / "before every push" reads as three independent
  full reviews per session. Agents then re-run the whole sweep redundantly, or perceive a
  contradiction with the "run once per feature" rule.
- The review skill already guarantees single-run-per-change behavior (idempotent within a
  session; scoped re-reviews against `git diff <cleared-sha>..HEAD`). The workflow just has to
  reference that contract once, not restate the invocation per phase.

**Where**

- `skills/workflow/SKILL.md` Phase 4 (single-gate declaration + idempotency bullets) and the
  Skill Reference row (collapsed to Phase 4 only).
