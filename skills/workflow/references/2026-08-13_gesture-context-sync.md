---
class: principle
source: learnings/skills/workflow/2026-08-13_sidepanel-open-gesture-context.md
date: 2026-08-13
---

## Gesture-context APIs must fire synchronously

Platform APIs requiring user-gesture context must be called within the
synchronous call stack of the gesture event handler. Any `await` before the
call breaks the gesture-context chain.

**Failure mode:** the API silently drops the request — no error, no rejection,
no console warning. The feature simply stops working.

**Guard:** fire the gesture-context API in the same synchronous tick as the
handler. Run async work (state updates, network calls) in parallel via
fire-and-forget (`void promise.catch(…)`), never sequenced before the
platform call.

**Landed in:** `SKILL.md` Code Standards → "Platform-API traps" bullet (b).
