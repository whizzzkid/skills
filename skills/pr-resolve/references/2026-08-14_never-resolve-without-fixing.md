---
class: principle
severity: high
escalation: baseline → Important (rung 2)
source: learnings/skills/pr-resolve/2026-08-14_never-resolve-without-fixing.md
---

## Never resolve a review thread without first implementing the fix

Agent resolved a review thread via GraphQL `resolveReviewThread` without
implementing the underlying code fix. Resolution was treated as a bookkeeping
step rather than a post-fix confirmation step.

Existing Hard Rule 3 said "after a fix" but did not make the ordering explicit.
Escalated to **Important** with explicit sequencing: implement fix → commit →
push → resolve.

**Landed in:** `SKILL.md` Hard Rule 3 → "Important — only resolve threads you
actually worked on."
