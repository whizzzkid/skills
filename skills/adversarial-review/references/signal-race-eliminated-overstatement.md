---
class: principle
---

**Rule**

Flag any comment claiming a concurrency/signal race is "eliminated" or "removed"
when the fix only reorders an unregister (e.g. `signal.Stop`). Reword to "narrows
the window" unless a done-channel or atomic-flag guard truly closes it. Sweep 2.41.

**Why**

`signal.Stop` unregisters future deliveries but does not drain the buffered
channel — a signal already queued still executes the exit path. The window
narrows but is not zero; an overstated comment misleads future maintainers.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.41.
