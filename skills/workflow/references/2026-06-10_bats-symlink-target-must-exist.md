---
class: principle
date: 2026-06-10
skill: wk-workflow
severity: high
---

- **Rule:** A symlink-escape guard test must point at a file guaranteed to
  exist on every test OS (`/etc/passwd`) — never one that may be absent
  (`/etc/hostname` on macOS). Confirm the test fails when the guard is
  removed.
- **Why:** `[[ -f "$x" ]]` follows the symlink and tests the resolved
  target; a dangling symlink returns false, firing the "no file" branch
  instead of the escape guard — the test exits 0 vacuously.
- **Where:** Phase 3, "Behavioral tests must reach the guarded branch".
