---
name: bugfix-needs-regression-test
description: Commits with fix/bugfix subjects must add a paired test in the same commit.
class: principle
---

- **Rule:** For every commit whose subject matches
  `^(fix|bugfix|bug)[:(]`, the same commit must touch a paired
  test file. Source change without a test in the same commit is
  flagged: suggestion for one-line defensive fixes with existing
  parallel spec coverage; blocker when the fix introduces a new
  branch.
- **Why:** Without a regression test asserting the post-fix
  behavior, a future refactor can silently revert the fix. The
  fix lands once, the gap persists indefinitely.
- **Where:** Sweep 2.15 (Workstyle pass),
  "Bugfix-without-regression-test" bullet.
