---
skill: wk-goodmorning
date: 2026-05-29
type: correction
severity: high
---

Stale `last_working_day` marker causes yesterday's anchor to skip an entire working day.

**What happened:** The `last_working_day` marker is written by wk-goodevening. When the
user skips running goodevening, the marker stays frozen at the last evening-wrapped day.
The next morning brief blindly trusts the marker, anchors "yesterday" to the wrong day,
and the standup `👈🏽 Yesterday` section re-reports already-posted achievements while
carry-overs miss all the intervening day's work.

**Root cause:** Stage 0 bootstrap treats `last_working_day` as authoritative with no
cross-check against what day directories actually exist in `sitrep/`. A day that has
`morning.md` but no `evening.md` is an unambiguous signal that goodevening was skipped —
the skill never inspects for this pattern.

**Suggested fix:** After reading `last_working_day`, scan for sitrep day directories
between that date and today. For each intervening directory, check:
- Has `morning.md` or `morning.html` → was a working day
- Has no `evening.md` → goodevening was skipped

If any such directory is found, treat the **most recent directory with `morning.md`** as
the true last working day instead of the marker. Warn the user:

> "⚠️ `last_working_day` marker says {marker_date} but {newer_date} has a morning brief
> with no evening wrap. Using {newer_date} as yesterday. Run `wk-goodevening` for
> {newer_date} to fill the gap."

**Scope constraint (user-specified):** Only apply this override for consecutive-workday
gaps (1–3 days). After a genuine weekend or holiday (>3 calendar days since the marker),
the stale marker is expected and correct — do not override it.

**Detection logic (bash sketch):**
```bash
MARKER=$(cat "$SITREP_ROOT/last_working_day")
TODAY=$(date +%Y-%m-%d)
OVERRIDE=""
# Walk candidate dirs between marker+1 and yesterday
d="$MARKER"
while true; do
  d=$(date -v+1d -jf %Y-%m-%d "$d" +%Y-%m-%d 2>/dev/null || date -d "$d + 1 day" +%Y-%m-%d)
  [ "$d" = "$TODAY" ] && break
  DIR="$SITREP_ROOT/$(echo $d | tr - /)"
  if [ -f "$DIR/morning.md" ] && [ ! -f "$DIR/evening.md" ]; then
    OVERRIDE="$d"
  fi
done
GAP_DAYS=$(( ( $(date -jf %Y-%m-%d "$TODAY" +%s 2>/dev/null || date -d "$TODAY" +%s) \
             - $(date -jf %Y-%m-%d "$MARKER" +%s 2>/dev/null || date -d "$MARKER" +%s) ) / 86400 ))
if [ -n "$OVERRIDE" ] && [ "$GAP_DAYS" -le 3 ]; then
  YESTERDAY="$OVERRIDE"
  # warn user
fi
```
