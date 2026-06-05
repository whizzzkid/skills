---
class: principle
---

- **Rule:** When a change adds a new config field, env var, JSON output field,
  or CLI flag, write/update the user-facing doc in the same session unprompted;
  for a new config-schema section, also add a `docs/specs/` entry.
- **Why:** Multi-commit implementations leave docs untouched until the user
  interrupts to ask for them; new configurable surfaces are the predictable
  trigger that the passive "update affected docs" scan misses.
- **Where:** wk-docs Step 1 — "New configurable surface → mandatory doc".
