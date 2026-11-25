---
class: principle
---

Mechanics for `/wk-sharpen loop …`: the self-paced batch loop. This file holds the
exclusivity rules (below) plus the spawn / trigger / stop procedure. Two triggers
share one cycle: **watch** (file-change subscriber, preferred) and **interval**
(timed re-wake, the fallback).

## Argument parsing

- `loop watch [<N>mins]` → event-driven: a cycle starts when a learning arrives. `N`,
  if given, is the fallback interval used only when the watcher is unavailable (see
  [Watch trigger](#watch-trigger--subscribe-never-poll)).
- `loop <N>mins` → interval: `N` = minutes between the **end** of one cycle and the
  start of the next (`loop 15mins` → 15). Bare minutes (`loop 15`) read as minutes too.
- `N` missing or unparseable where the interval trigger needs it → ask once. Never
  assume a cadence; a guessed interval is the failure mode this mode exists to prevent.
- `loop stop` → stop the watcher task (`TaskStop`) or cancel the schedule, release the
  lock if this session holds it, report the last cycle's counts, exit.

## Exclusivity — one drain per machine

- At most one drain worker runs per machine, across all sessions. Enforce it with the
  drain lock, never by convention:

  ```bash
  "<skill-dir>/scripts/watch-queue.sh" lock "<owner>"    # rc 0 acquired, 1 held
  "<skill-dir>/scripts/watch-queue.sh" unlock "<owner>"  # only the owner releases
  ```

  - `<skill-dir>` is the base directory the skill loads from. `<owner>` is one tag
    per loop session (e.g. `loop-<epoch>`), chosen once and reused for every cycle.
  - The lock is an atomic `mkdir` in the repo's git common dir, so it is never
    committed and is shared by every worktree. A lock older than
    `WK_SHARPEN_LOCK_TTL_SECONDS` (default 4h) belongs to a dead session and is
    reclaimed (`LOCK_RECLAIMED`).
- Acquire before spawning the worker, release after its completion notification:
  both triggers, every cycle. `LOCK_HELD` → a peer session is draining; spawn
  nothing and re-arm (the watcher waits out a live lock on its own).
- The dispatcher never folds an item itself and never spawns a second agent to
  parallelize the drain.

## One cycle

1. Take the lock. Then spawn **exactly one** background subagent whose prompt is this
   skill in batch mode, told to **drain the queue to empty**. Nothing else runs in the
   cycle.

   ```
   Agent(prompt="Invoke the wk-sharpen skill via the Skill tool and drain EVERY
   unprocessed learning: highest-severity, oldest-mtime first; fold, commit, push,
   re-list, repeat until the Source 2 listing is empty. Do not invoke wk-learn or
   wk-retro: return the cycle summary to this dispatcher without creating queue files",
   run_in_background=true)
   ```

   - **Fresh `Agent` call every cycle — zero inherited context.** Never continue a
     prior cycle's agent by message: a cycle's context is spent on the items it
     already folded, and a stale queue snapshot re-claims processed items.
   - The worker never writes a learning or retrospect about its own cycle. Those
     records re-enter Source 2/4 and turn an idle queue into permanent self-work.
2. Wait for that agent's completion notification. Never poll for it by spawning
   another agent, never start a second cycle while one is live, and never report a
   pending agent's findings — the notification is the only completion signal.
3. On completion, release the lock, then read what it landed: skills updated,
   learnings renamed to `.learned.md`, items left unclaimed or distilled-not-landed.
4. Re-arm the trigger (watch: start the watcher again; interval: schedule `N` minutes
   out), then end the turn.

### The agent's drain loop — inside one cycle

- Iterate until the queue is empty: pick the top item, run the full sharpen
  workflow, land it through Step 8's terminal gate, then **re-list** and pick again.
- One commit + one push per item — never batch several folds into one commit, and
  never defer pushes to the end of the drain (a mid-drain block would strand them).
- Re-list after *every* fold-commit, never once up-front: peers write continuously,
  so an item that arrived mid-drain is unclaimed backlog, not part of this pass.
- Stop the drain early on a blocked commit gate or a signing failure — report
  distilled-not-landed and leave the rest of the queue untouched.
- Items arriving after the drain started may be left for the next cycle; a cycle
  is done when it has drained everything that was waiting when it looked last.

## Watch trigger — subscribe, never poll

- Arm with a **one-shot background Bash task**, never `Monitor` (a monitor expires
  within 30 min, so re-arming it wakes the model more often than the poll it
  replaces):

  ```
  Bash(command='"<skill-dir>/scripts/watch-queue.sh" wait', run_in_background=true)
  ```

- The script is **level-triggered**: it lists the queue before subscribing and
  again after every file event, so the event only says "look again" and the listing
  decides. It exits once unprocessed work exists and no live lock is held, after a
  settle window (`WK_SHARPEN_SETTLE_SECONDS`, default 60) that folds a burst into
  one cycle. Arrivals during a drain or a re-arm gap are caught by the opening list;
  a dropped event is caught by the periodic recheck (`WK_SHARPEN_RECHECK_SECONDS`,
  default 900).
- It watches Source 1 (global inbox), Source 2 (`learnings/skills/`) and Source 4
  (`learnings/retrospect/`), counting `*.md` minus `*.learned.md` and following
  symlinks.
- Never armed while a worker runs: the worker's own renames and pulls cannot
  self-trigger, so no event filter for self-writes is needed.
- One watcher task outstanding per session. Act on its completion notification by
  exit code:

  | rc | Output | Action |
  |----|--------|--------|
  | 0 | `ARRIVED <n>` | Run one cycle |
  | 3 | `WATCHER_UNAVAILABLE` | No `fswatch`/`inotifywait` → interval trigger with `N`; no `N` → stop and report |
  | 4 or any other | `WATCHER_FAILED …` / killed | Re-arm once; a second consecutive failure → interval fallback as rc 3 |
  | 2 | usage/config error | Stop and report (`WK_SKILLS_HOME` unset or no queue dir) |

## Interval trigger — schedule from completion, never a fixed cadence

- Schedule with `ScheduleWakeup` (`delaySeconds: N*60`, the same `loop` prompt
  verbatim) so the next cycle is timed from *this* cycle's completion. A slow
  cycle pushes the next one back instead of overlapping it.
- **Never `CronCreate` for either trigger.** A cron fires on wall-clock cadence
  regardless of whether a cycle is still running, which stacks concurrent folds —
  the exact overlap the loop is designed to prevent.
- One scheduled wakeup outstanding at a time. Re-entering the loop replaces the
  schedule; it never adds a second one. Switching to watch cancels it.

## Termination

- Interval: queue empty at wake — `rc 0` **and** empty output from the Source 2
  listing (`watch-queue.sh pending` prints `0`) — → spawn nothing, report it,
  schedule the next interval. Watch never wakes on an empty queue.
- The loop runs continuously; peer sessions can refill an idle queue at any time.
- A cycle that ends distilled-not-landed (blocked commit gate, signing failure)
  → stop the loop and report it. Re-waking cannot clear a gate the run could not,
  so repeated cycles would burn the trigger without progress. Release the lock first.
- Interruption or a stop request wins immediately over any outstanding watcher or
  schedule.

## Why exclusivity is load-bearing

- Two cycles folding at once claim the same learning: neither sees the other's
  claim, because the `.learned.md` marker is a rename and `mv` preserves mtime, so
  neither mtime nor commit recency reveals a peer. Only the lock is visible to both.
- A byte-budget measurement taken by one cycle is voided by the other's edits
  landing mid-flight, so both can pass the ceiling check and still breach it.
- TTL reclaim is best-effort: two sessions reclaiming the same stale lock in the
  same instant can both win. A live session never trips it (cycles run well under
  the TTL).
