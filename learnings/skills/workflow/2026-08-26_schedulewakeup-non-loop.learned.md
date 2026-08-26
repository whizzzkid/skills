---
skill: wk-workflow
date: 2026-08-26
type: correction
severity: low
verified-against-source: n/a
---

Do not call ScheduleWakeup in a non-`/loop` session just to wait on a backgrounded task — the task notification already re-invokes the agent on completion.

**What happened:** While waiting for a backgrounded CI-poll command to finish during a PR-resolve flow, the agent called ScheduleWakeup with the autonomous-loop-dynamic sentinel — in a session that was never a `/loop`. It immediately recognized the mistake and issued a `stop:true` cancel.

**Root cause:** ScheduleWakeup is scoped to `/loop` dynamic mode; a plain background command (Bash `run_in_background`) already fires a task-notification that re-invokes the agent when it exits, so a manual wakeup is redundant and semantically wrong (it re-enters a loop that does not exist).

**Suggested fix:** When waiting on harness-tracked background work, do nothing but end the turn — the completion notification is the wake signal. Reserve ScheduleWakeup exclusively for `/loop` sessions or genuinely external, un-notified state (a remote queue/deploy the harness cannot track).
