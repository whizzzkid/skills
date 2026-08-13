---
class: principle
source: learnings/skills/workflow/2026-08-13_set-panel-behavior-suppresses-onclick.md
date: 2026-08-13
---

## Platform-API takeover — convenience APIs suppress event handlers

A platform convenience API that automates a user-facing action may take
exclusive ownership of that action and silently disable custom event handlers.

**Mechanism:** the API is designed as a replacement for manual handling, not an
additive layer — enabling it removes the event entirely from the application's
event loop.

**Guard:** before enabling any convenience API that automates a user-facing
action, verify in the platform's docs whether it suppresses the event handler
for the same action. If both native automation and custom handler logic are
needed, use the manual API variant alongside custom logic.

**Landed in:** `SKILL.md` Code Standards → "Platform-API traps" bullet (a).
