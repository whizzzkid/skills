---
name: inline-test-helper-tautology
description: Test helpers that copy production source bodies are tautological.
class: principle
---

- **Rule:** Flag new `let` / `before` / fixture / factory blocks
  whose body is an identical or near-identical copy of code in the
  production diff (threshold: >3 identical non-trivial lines).
- **Why:** Stubs applied to the copied body never exercise the real
  code path. The test passes regardless of drift in production —
  coverage becomes meaningless and any future bug ships silently.
- **Where:** Sweep 2.15 (Workstyle pass), "Inline test helpers
  duplicating production source" bullet.
