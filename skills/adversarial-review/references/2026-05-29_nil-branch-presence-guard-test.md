---
class: principle
skill: wk-adversarial-review
date: 2026-05-29
---

# Flag untested nil branch in presence-guarded builder methods

- **Rule:** In sweep 2.15, for any new method that can return nil via
  `.presence` (or a build-then-return-empty pattern), require a spec that stubs
  the controlling field to nil/blank and asserts a `nil` result; flag
  `suggestion` when absent.
- **Why:** The symmetric nil-return path of a `present?`-gated builder is
  behaviorally significant but uncovered when every existing spec supplies a
  valid value — a bot caught it after pre-flight missed it.
- **Where:** Sweep 2.15 (Workstyle pass) missing-test checklist.
