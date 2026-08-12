---
class: one-off
date: 2026-08-11
skill: wk-adversarial-review
---

# Fail-closed rescue branches are a reliable finding class

- **Scenario:** A bot flagged that a `rescue ActiveRecord::ActiveRecordError`
  branch in an Action Cable channel had no test, while equivalent controller-level
  rescues were tested.
- **Symptom:** Developers test the happy path and explicit-denial path but skip
  the infrastructure-failure rescue, especially in non-controller contexts.
- **Fix:** When reviewing code with a `rescue` in a security-critical path, scan
  for a matching spec exercising the rescue: stub the dependency to raise, assert
  the fail-closed outcome and the observability side effect.
- **Why not promoted:** Sweep 2.15 already covers sad-path gaps and error-handling
  findings. This is a high-confidence sub-pattern within that sweep. Body at ceiling.
