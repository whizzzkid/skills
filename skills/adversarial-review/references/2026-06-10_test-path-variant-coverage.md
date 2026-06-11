---
class: principle
date: 2026-06-10
skill: wk-adversarial-review
---

- **Rule:** For test-only commits, enumerate the distinct code paths through
  each function under test and verify a new test exercises each; flag
  unexercised paths as `suggestion`.
- **Why:** Coverage checks that look only for test-function presence miss an
  untested fallback path (e.g. a different `dirname` result), caught only on
  a second adversarial pass.
- **Where:** Step 3 subagent dispatch — "Coverage-aware (test-only
  commits)".
