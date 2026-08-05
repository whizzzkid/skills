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
- Canonical close requires `end_completed_at:`, the dated snapshot, the
  carry-forward heading + scrub note, and no dirty or unpushed close artifacts
  in `git -C "$SITREP_REPO" status --short --branch`.
- Legacy close without `end_completed_at:` passes only when the snapshot,
  carry-forward heading, scrub note, and clean/pushed state all exist.
- Marker plus dirty/ahead state → finish `end` Stage 8 first. Failure stops
  `start`.

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
  ```

- Run `end` Stages 1–8 unchanged. On retry, re-read the existing snapshot and
  append only entries not already present; only Stage 8 writes
  `end_completed_at:`.
- Any failure stops `start` before today's `live.md` can be written.

## Restore today's start

- Re-run Step 0 to restore `$TODAY`, snapshot paths, and current-week registry.
- Continue at `start` Stage 1 so the scrubbed carry-forward page is the input.
- Omit the prior `end_completed_at:` when Stage 4 writes today's frontmatter.
