---
class: principle
---

Mechanics for `/wk-sharpen loop <N>mins` — the self-paced batch loop. The
exclusivity rules live in `SKILL.md`; this file holds the spawn / schedule / stop
procedure.

## Argument parsing

- `loop <N>mins` → `N` = minutes between the **end** of one cycle and the start of
  the next (`loop 15mins` → 15). Bare minutes (`loop 15`) read as minutes too.
- `N` missing or unparseable → ask once. Never assume a cadence; a guessed
  interval is the failure mode this mode exists to prevent.
- `loop stop` → cancel scheduling, report the last cycle's counts, exit.

## One cycle

1. Spawn **exactly one** background subagent whose prompt is this skill in batch
   mode. Nothing else runs in the cycle.

   ```
   Agent(prompt="Invoke the wk-sharpen skill via the Skill tool and drain the
   highest-severity, oldest-mtime unprocessed learning ... one item only",
   run_in_background=true)
   ```

2. Wait for that agent's completion notification. Never poll for it by spawning
   another agent, never start a second cycle while one is live, and never report a
   pending agent's findings — the notification is the only completion signal.
3. On completion, read what it landed: skills updated, learnings renamed to
   `.learned.md`, items left unclaimed or distilled-not-landed.
4. Schedule the next cycle `N` minutes out, then end the turn.

## Scheduling — from completion, never a fixed cadence

- Schedule with `ScheduleWakeup` (`delaySeconds: N*60`, the same `loop` prompt
  verbatim) so the next cycle is timed from *this* cycle's completion. A slow
  cycle pushes the next one back instead of overlapping it.
- **Never `CronCreate` for this mode.** A cron fires on wall-clock cadence
  regardless of whether a cycle is still running, which stacks concurrent folds —
  the exact overlap the loop is designed to prevent.
- One scheduled wakeup outstanding at a time. Re-entering the loop replaces the
  schedule; it never adds a second one.

## Termination

- Queue drained — `rc 0` **and** empty output from the Source 2 listing — → report
  counts and stop scheduling (`ScheduleWakeup` with `stop: true`). Do not keep
  waking on an empty queue.
- A cycle that ends distilled-not-landed (blocked commit gate, signing failure)
  → stop the loop and report it. Re-waking cannot clear a gate the run could not,
  so repeated cycles would burn the interval without progress.
- Interruption or a stop request wins immediately over any outstanding schedule.

## Why exclusivity is load-bearing

- Two cycles folding at once claim the same learning: neither sees the other's
  claim, because the `.learned.md` marker is a rename and `mv` preserves mtime, so
  neither mtime nor commit recency reveals a peer.
- A byte-budget measurement taken by one cycle is voided by the other's edits
  landing mid-flight, so both can pass the ceiling check and still breach it.
