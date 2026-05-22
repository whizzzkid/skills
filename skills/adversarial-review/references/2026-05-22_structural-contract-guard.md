---
name: structural-contract-guard
description: Refactors that swap constrained shape for open merge/spread must add a collision guard.
class: principle
---

- **Rule:** Grep the diff for `merge` / `update` / `Object.assign`
  / spread / `**kwargs` writes into a structural container. For
  each hit, verify the same commit adds an allowlist /
  reserved-key constant / collision guard. Missing guard →
  suggestion; blocker when the container has named fields the
  caller could shadow.
- **Why:** Pre-refactor, the constrained shape enforced safety by
  construction. Post-refactor, safety relies on caller discipline
  — silent overwrites of structural fields by user-controlled
  keys ship undetected.
- **Where:** Sweep 2.7 (signature widening pre-flight),
  "Structural-contract widening" block.
