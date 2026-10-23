---
class: principle
date: 2026-10-23
source:
  - learnings/skills/pr-review/2026-10-23_shared-ref-rule-numbers.learned.md
severity: medium
---

- **Rule:** When a changed file is included or referenced by other files, grep for every consumer and resolve each
  numbered or named reference the change adds or edits (rule N, step N, a section name) inside each consumer — not
  only the primary one. Applies in every mode; it is a static grep check.
- **Why:** A shared include is read in each consumer's own numbering context. A reference that is correct for one
  includer can point at an unrelated rule in another, and the diff shows only the shared file, so reviewing against the
  primary consumer passes the mismatch.
- **Where:** `SKILL.md` → Phase 3 → "Shared file → check every consumer" paragraph, after the derivation HARD RULE.
