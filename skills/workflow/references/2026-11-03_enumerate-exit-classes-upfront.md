---
class: principle
---

# Enumerate termination classes before patching an "every path" invariant

- **Rule:** When a fix promises that no path leaves X in state Y, write the termination matrix first — each
  deliberate exit code, uncaught exception, signal, external update refused once and twice, crash before vs after the
  success write — and test every cell before the first push.
- **Why:** A "never block the merge" fix drew one new review-bot finding per push for six rounds: an in-progress check
  left by an unrescued exception, exits before the safety net registered, a fallback level, a crash's exit status, a
  crash after delivery misreported, a signal turned into success. The invariant was patched path by path instead of
  checked against a complete list of how the process can end.
- **Where:** [`wk-workflow`](../README.md) → Phase 3: Test; also listed in
  [`edit-scope-preflights.md`](edit-scope-preflights.md).
