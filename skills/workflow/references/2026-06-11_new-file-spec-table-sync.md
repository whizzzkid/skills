---
class: principle
---

- **Rule** — When a commit adds a new file (extracted base class, helper
  module), update the spec's New Files / Modified Files tables in the same
  commit — part of the file's creation, not deferred docs cleanup.
- **Why** — A new file without its spec-table row leaves the spec stale until
  the adversarial cross-doc sweep flags it, forcing an extra fix commit.
- **Where** — Phase 2 (Implement), new sub-section "New-file spec-table sync",
  beside "Design pivots travel with their docs" and "Test enumeration sync".
