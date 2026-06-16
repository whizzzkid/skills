---
class: principle
date: 2026-06-16
---

- **Rule:** When a diff dedups per-method tests into a shared_examples /
  parameterized block, audit three caller-specific gaps: per-caller log/warn
  labels, higher-level integration (bin/controller) coverage, and caller
  env-var fallbacks only reachable through the real entry point.
- **Why:** Shared examples test common logic but obscure caller-specific
  behavior that existed in the replaced per-method blocks.
- **Where:** Sweep 2.15 (workstyle pass) — shared-example dedup coverage bullet.
