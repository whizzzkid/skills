---
class: principle
skill: wk-workflow
date: 2026-06-09
severity: medium
---

- **Rule:** Before scaffolding a new skill/command/entry point, ask whether
  the capability is a new verb on a noun an existing skill already owns; if
  so, add a routing mode (`/foo bar`) instead of a parallel skill
  (`/foo-bar`).
- **Why:** Building a parallel entry point for a subcommand-shaped capability
  is reverted later — the user expects a mode of the existing skill.
- **Where:** Phase 1: Plan, "New-capability probe — extend an existing skill
  before scaffolding a new one".
