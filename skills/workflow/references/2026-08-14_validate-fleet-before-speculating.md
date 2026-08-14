---
class: principle
severity: high
source: learnings/skills/workflow/2026-08-14_validate-fleet-before-speculating.md
---

## Fleet validation for shared integrations

When fixing integration code that uses a shared gem, library, or org-wide
service, grep 2-3 sibling repos for the same integration pattern before
proposing changes. Fleet consensus outranks spec correctness.

**Landed in:** `SKILL.md` Phase 2 → "fleet-first for shared integrations" bullet.
