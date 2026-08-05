---
class: principle
---

# Missed-end rollover

Canonical procedure for `start` Stage 0.5. Closing the prior live page is a
prerequisite to today's overwrite, not a separate required invocation.

## Detect closure

- Read `$LIVE_FILE`; no file or `date:` equal to `$TODAY` → skip rollover.
- Missing, malformed, or future `date:` → stop; never guess which day to close.
- Resolve that date's snapshot before judging state.
- Close artifacts are `$LIVE_FILE`, the dated snapshot, `$WEEK_MEM_FILE`, and
  `$EMPLOYER/QPR/brag-log.md` when present. Inspect repository-wide
  `git status --short --branch`; any dirty path outside this allowlist stops
  `start` and is never staged by rollover.
- Canonical close requires `end_completed_at:`, the dated snapshot,
  carry-forward heading + scrub note, and a committed marker proven by
  `git log -1 -S'end_completed_at:' -- "$LIVE_FILE"` while every close artifact
  is clean.
- Legacy close without `end_completed_at:` passes only when the snapshot,
  carry-forward heading, scrub note, and every close artifact are clean.
- Marker absent from commit history, or any dirty close artifact → rerun the
  full dated `end` flow from Stage 1. Never jump directly to Stage 8.
- Clean committed close + branch ahead → push only when every path in the ahead
  range is a close artifact; an unrelated path or failed push stops `start`.

## Run the missed close

- Save the actual-day context. Bind the nested `end` flow's logical "today" to
  the prior `date:` and bound every gathering query to that local calendar day.
- Derive the dated snapshot path without platform-specific `date` parsing:

  ```bash
  CLOSE_DATE="$LIVE_DATE"
  CLOSE_YEAR="${CLOSE_DATE%%-*}"
  CLOSE_MONTH_DAY="${CLOSE_DATE#*-}"
  CLOSE_MONTH="${CLOSE_MONTH_DAY%%-*}"
  CLOSE_DAY="${CLOSE_DATE##*-}"
  SNAPSHOT_DIR="$SITREP_REPO/$EMPLOYER/$CLOSE_YEAR/$CLOSE_MONTH/$CLOSE_DAY"
  SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot.md"
  SNAPSHOT_URL="http://localhost:$SITREP_PORT/$EMPLOYER/$CLOSE_YEAR/$CLOSE_MONTH/$CLOSE_DAY/snapshot"
  ```

- Run `end` Stages 1–8 with this logical date. Never read wall-clock dates for
  a nested end snapshot path, URL, announcement, or gathering window.
- On retry, re-read the existing snapshot and append only entries not already
  present; only Stage 8 writes `end_completed_at:`.
- Any failure stops `start` before today's `live.md` can be written.

## Restore today's start

- Re-run Step 0 to restore `$TODAY`, snapshot path + URL, and current-week
  registry.
- Continue at `start` Stage 1 so the scrubbed carry-forward page is the input.
- Omit the prior `end_completed_at:` when Stage 4 writes today's frontmatter.
