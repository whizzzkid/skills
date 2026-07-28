---
name: wk-sharpen-drain
description: >-
  Drain the undistilled-learning queue through wk-sharpen one run at a time.
  Owns the queue order, the single-run-in-flight lock, and the per-item
  completion check, so folds never overlap and a cadence tick firing during an
  active run skips instead of stacking. Use for "drain the learnings", "sharpen
  the queue", "keep folding learnings", or on a schedule/loop. Dispatcher only —
  wk-sharpen still owns every edit to a SKILL.md.
argument-hint: '[--max=N] [--status] [--release]'
allowed-tools:
  - Bash
  - "Bash(mkdir:*)"
  - "Bash(find:*)"
  - "Bash(git status:*)"
  - "Bash(git log:*)"
  - Skill
model: sonnet
effort: high
user-invocable: true
disable-model-invocation: true
license: MIT
group: workflows
env-vars:
  - WK_SKILLS_HOME
metadata:
  author: whizzzkid
  version: '2026.07.28-154518'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Sharpen Drain

Dispatch `wk-sharpen` over the undistilled-learning queue **serially** — one
fold in flight, ever. This skill never edits a `SKILL.md`; it decides *which*
learning is folded *when*, and refuses to start a second run while one is live.

## When to Use

- "Drain the learnings", "sharpen the queue", "keep folding learnings".
- Any cadence trigger — a schedule, a `/loop`, a wake-up — that wants folds to
  keep progressing unattended.
- Not model-invocable by design: the failure this skill exists to prevent is an
  agent spawning concurrent folds on its own.

## HARD RULE: one run in flight, always

- Exactly one fold may be running across the whole machine — not per session,
  per agent, or per worktree. Concurrent folds contend over the same queue and
  the same `SKILL.md` files: two runs claim one learning, and one run's byte
  budget is voided by the other's edits landing mid-flight.
- A tick that finds the lock held **skips** — exit 0, report the holder's age,
  never queue, wait, or stack a second run.
- Never spawn a fold as a background agent, and never spawn more than one agent
  from this skill. The run happens inline in this session so its completion is
  observable; a backgrounded fold is exactly the pattern that produced four
  simultaneous runs.

## Step 1: Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

Missing → stop and tell the user to export `$WK_SKILLS_HOME`; never guess the
repo path.

## Step 2: Acquire the lock

The lock lives outside the repo so it never dirties the tree or reaches a
commit. `mkdir` is the atomic primitive — `test -e` then create is a TOCTOU race
that lets two ticks both believe they won.

```bash
LOCK="${TMPDIR:-/tmp}/wk-sharpen-drain.lock"
if mkdir "$LOCK" 2>/dev/null; then
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$LOCK/started-at"
  echo "ACQUIRED"
else
  echo "HELD since $(cat "$LOCK/started-at" 2>/dev/null || echo unknown)"
fi
```

- `ACQUIRED` → continue to Step 3.
- `HELD` → a drain is live. Report the holder's start time in one line and
  **stop**. This is a success, not an error — exit without a fold.

### Stale-lock reclaim

A killed or crashed run leaves the directory behind and would wedge the queue
forever, so a lock older than the threshold is reclaimable.

```bash
STALE_MINUTES="${WK_DRAIN_STALE_MINUTES:-90}"
find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'wk-sharpen-drain.lock' -type d \
  -mmin "+$STALE_MINUTES" -print
```

- Non-empty output → say the lock is stale and how old, `rm -rf` it, re-run
  Step 2 once. A second acquire failure means a live peer took it — skip.
- Never reclaim a lock younger than the threshold to "unblock" yourself; a
  slow fold is still a fold.
- `/wk-sharpen-drain --release` → release the lock and exit, for the case where
  the user knows a run died. `--status` → report lock state and queue depth,
  then exit without folding.

### Release on every exit path

Release the lock when the loop ends — queue drained, item stuck, user
interrupt, or error. A drain that exits without releasing turns every later tick
into a skip.

```bash
rm -rf "${TMPDIR:-/tmp}/wk-sharpen-drain.lock"
```

## Step 3: Pre-flight — no half-finished fold in the tree

A previous run that edited a skill but never committed means the queue is
mid-fold. Folding a second learning on top entangles two changes in one commit
and voids both byte budgets.

```bash
git -C "$WK_SKILLS_HOME" status --porcelain -- skills/
```

- Non-empty → stop. Report the dirty paths and tell the user to land or discard
  that fold first; release the lock. Do not fold on top of it.
- Untracked files under `learnings/` are expected state (undistilled queue
  items) — scope the check to `skills/` so they never read as debris.

## Step 4: Build the queue

Undistilled = a plain `.md`; `.learned.md` marks an already-folded file.

```bash
cd "$WK_SKILLS_HOME"
find learnings -type f -name '*.md' ! -name '*.learned.md' -print0 \
  | xargs -0 stat -f '%m %N' \
  | LC_ALL=C sort -n
```

- Oldest `mtime` first — the queue is FIFO so a long-tail learning cannot be
  starved by newer arrivals. `wk-sharpen` applies its own severity ordering
  *within* a run; this skill does not re-rank.
- **Empty queue is a verdict, not a banner** — `rc 0` **and** empty output means
  drained. A non-zero rc is an error: report it and stop, never report "drained".
- Print the depth before folding: `"queue: N undistilled (oldest: <path>)"`.
- `--max=N` caps how many items this invocation folds; default is the whole
  queue. The cap is reported in the closing summary, never applied silently.

## Step 5: Fold exactly one item

Take the head of the queue and hand that single path to `wk-sharpen`. The
skill's short name is the second path segment under `learnings/skills/`; a file
under `learnings/retrospect/` has no owning skill — pass the path alone and let
`wk-sharpen` route it.

```
Skill(wk-sharpen, args="<skill-short-name> <path-to-learning>")
```

- One item per invocation of `wk-sharpen`. Never pass the queue, a glob, or a
  count — batch mode inside a single run is `wk-sharpen`'s business, but this
  dispatcher hands it one incident so the completion check below is unambiguous.
- Do not read or edit the target `SKILL.md` yourself, and do not pre-judge the
  fold. A dispatcher that "helps" splits ownership of the edit.

## Step 6: Verify the run completed before advancing

A run is complete only when it reached a terminal state. Advancing on an
unverified run is how a stuck item silently burns the whole queue.

Terminal states, any one of which counts:

- **Folded** — the learning is now `*.learned.md` **and** a commit exists for
  it. Verify both; a rename without a commit is an unfinished run.
- **Verdict recorded** — `wk-sharpen` rejected the fold, routed it privately, or
  returned `distilled-not-landed`, and said so. The file may stay a plain `.md`.

```bash
git -C "$WK_SKILLS_HOME" log --oneline -1
git -C "$WK_SKILLS_HOME" status --porcelain -- skills/
```

- Neither state reached, or `skills/` is dirty → the item is **stuck**. Stop the
  loop, name the item and what the run left behind, release the lock. Never
  retry the same item twice in one drain and never skip past it silently — a
  silent skip makes a broken fold look drained.
- Item still queued but the run reported a verdict → leave it queued and move on;
  `wk-sharpen` owns the rename.

## Step 7: Re-list and repeat

Re-run Step 4 before each item; never reuse the Step 4 listing across folds. A
fold can rename its own file, land a peer's, or add a re-queued item, so a cached
queue advances onto a path that no longer exists.

- Loop Steps 4–6 until the queue is drained, `--max=N` is reached, or an item is
  stuck.
- Release the lock (Step 2) and print the closing summary:
  `"drained: N folded, M stuck, K remaining (cap: <--max or none>)"`.
- Report `remaining > 0` explicitly. "Done" with items left is the report this
  skill exists to prevent.

## Quick Reference

| Invocation | Behavior |
|---|---|
| `/wk-sharpen-drain` | Drain the whole queue, one fold at a time |
| `/wk-sharpen-drain --max=3` | Fold at most 3 items, then report the remainder |
| `/wk-sharpen-drain --status` | Lock state + queue depth; no fold |
| `/wk-sharpen-drain --release` | Release a lock left by a dead run |
| Lock already held | Skip the tick, exit 0, report holder age |

## Common Mistakes

- **Stacking on a cadence.** An interval firing every N minutes will outpace a
  fold. The lock — not the interval — decides whether work starts.
- **Backgrounding the fold.** A fire-and-forget agent per tick is the exact
  pattern that produced four concurrent runs; the fold runs inline.
- **Advancing on an unverified run.** "The skill returned" is not "the fold
  landed" — check the rename *and* the commit.
- **Caching the queue.** Re-list before every item; folds mutate the queue.
- **Reclaiming a live lock.** A slow fold looks identical to a dead one until the
  staleness threshold passes. Wait for it.
- **Reporting "drained" off a banner.** Empty output with a non-zero rc is a
  broken listing, not an empty queue.

## Requirements

- `$WK_SKILLS_HOME` set to the skills repo root
- `wk-sharpen` installed (owns every `SKILL.md` edit)
- Write access to `${TMPDIR:-/tmp}` for the lock

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn sharpen-drain`).
