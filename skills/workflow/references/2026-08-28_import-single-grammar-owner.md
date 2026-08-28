---
class: principle
skill: wk-workflow
source: learnings/skills/workflow/2026-08-28_import-single-grammar-owner.md
date: 2026-08-28
---

## Principle

Before writing helper logic that parses, serializes, or enforces a shared
format/contract, grep for the existing owner of that grammar and import from
it. Extract only genuinely helper-specific pure logic into a new module.

## Failure Mode

A new helper re-implemented a URL-hash grammar an existing module already
owned. Review flagged the module-boundary violation, forcing a follow-up to
collapse the duplicated grammar back to a single owner.

## Landing

Added "Shared-contract ownership" bullet to Phase 2 Edit-scope pre-flights.
