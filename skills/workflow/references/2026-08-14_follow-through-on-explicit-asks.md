---
class: principle
severity: medium
source: learnings/skills/workflow/2026-08-14_follow-through-on-explicit-asks.md
---

## Track mid-session explicit requests as deliverables

Existing rule covered initial-prompt deliverable enumeration. Gap: mid-session
explicit user requests (e.g., "create a follow-up PR for X") were silently
dropped because the agent treated them as commentary rather than actionable
tasks.

**Landed in:** `SKILL.md` Continuity Rules → "Important: Enumerate every deliverable" bullet (extended to cover mid-session asks).
