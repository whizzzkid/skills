---
class: principle
date: 2026-05-25
source: learnings/skills/wk-adversarial-review/2026-05-22_happy-path-coverage-asymmetry.md
---

- **Rule:** When a field is populated unconditionally in a method that has both pass and fail return paths, require at least one assertion of that field's value on each return path. Tests that cover only the "interesting" failure cases let a short-circuit regression on the happy path slip through.
- **Why:** Writing tests for a new field biases toward edge cases (nil, blocked, disabled); the symmetric allowed/passing case where the same field is populated is easy to forget, and a regression there would not flip any existing assertion.
- **Where:** Step 3 "Categories to hunt" — Test quality row extended with "asymmetric coverage of fields populated on both pass and fail return paths."
