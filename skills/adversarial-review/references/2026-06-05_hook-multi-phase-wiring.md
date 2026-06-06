---
class: principle
date: 2026-06-05
---

- **Rule:** When a hook-config command's tag/name claims multiple hook
  phases, verify the YAML wires every claimed phase — anchor defined
  and referenced under each phase.
- **Why:** A command authored under one phase with a dual-phase tag but
  no anchor/reference enforces only that one phase; the tag claims
  enforcement it never delivers.
- **Where:** Step 2, sweep 2.14 (Pre-push gate compliance) — Multi-phase
  wiring check.
