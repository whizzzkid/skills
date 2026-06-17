---
class: principle
---

# A directive copied from a sibling template must carry its contract

**Rule**

- When a directive (`soft_fail`, `retry`, `timeout`, exit-code handling) is copied
  from a sibling template, verify the sibling's behavioral/exit-code contract
  actually transfers to the new step. Pattern copy ≠ contract transfer.
- A copied directive whose contract does not hold is a blocker; quote the sibling's
  contract if documented, else flag pending verification.

**Why**

- A publish step copied `soft_fail [{ exit_status: 1 }]` from a validation sibling
  whose contract intentionally emits 0/1/75 for different outcomes. The publish step
  has no such contract — any failure is team-actionable and must hard-fail, so the
  copied `soft_fail` would silently swallow real errors.
- Sweep 2.2 checked that fixes are applied *to* siblings, not that a directive
  copied *from* a sibling still means the same thing in its new home.

**Where**

- `skills/adversarial-review/SKILL.md` Step 2 sweep 2.2 (contract-transfer clause).
