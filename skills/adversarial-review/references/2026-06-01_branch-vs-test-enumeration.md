---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: high
---

- **Rule:** For every new multi-branch function (>2 return paths), count
  its distinct return/exit paths and the named test cases that exercise
  it; flag any path with no covering test.
- **Why:** A green suite does not imply full branch coverage — a
  multi-branch function can pass with several return paths untested, and
  a bot reviewer flags the gap after push.
- **Where:** Step 2 → sweep 2.15 (Workstyle pass) → new branch-vs-test
  enumeration bullet (blocker when an uncovered path changes observable
  behavior).
