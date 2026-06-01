---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: high
---

- **Rule:** A test shim (including a shell heredoc) that duplicates a
  security-sensitive production function is a `blocker`-class
  duplication finding, not a mere `test-tautology` suggestion.
- **Why:** A patch to the production guard (symlink-escape,
  path-traversal, credential redaction, auth check) leaves the test
  validating stale logic — the suite stays green while the real guard
  regresses.
- **Where:** Step 2 → sweep 2.15 (Workstyle pass) → extended the
  inline-test-helper-duplication bullet to cover heredoc function defs
  and added the security-sensitivity severity escalation.
