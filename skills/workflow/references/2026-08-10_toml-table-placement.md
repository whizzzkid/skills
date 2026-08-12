---
class: principle
date: 2026-08-10
skill: wk-workflow
---

# TOML table scope traps global-key insertion

- **Rule:** Before patching a TOML file, identify the first `[table]` header and
  insert global keys immediately above it. TOML table scope extends until the next
  header — a context-free append after the last table silently nests keys inside
  that table. Validate both parsing and the resolved configuration after insertion.
- **Why:** A patch appended global settings after the final table header, silently
  nesting them inside that table instead of applying them at the top level.
- **Where:** Phase 2 → Code Standards → Niche standards →
  `code-standards-extended.md` (TOML-table-anchoring).
