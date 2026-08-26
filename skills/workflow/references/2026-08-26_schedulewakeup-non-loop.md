---
class: one-off
source: learnings/skills/workflow/2026-08-26_schedulewakeup-non-loop.md
---

# ScheduleWakeup is scoped to /loop sessions only

Do not call ScheduleWakeup in a non-loop session to wait on a backgrounded
task. The task notification from run_in_background already fires a wake
signal. ScheduleWakeup re-enters a loop that does not exist.

Reserve ScheduleWakeup exclusively for /loop sessions or genuinely external,
un-notified state the harness cannot track.
