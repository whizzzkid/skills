---
skill: wk-sitrep
date: 2026-11-03
type: gap
severity: medium
verified-against-source: n/a
---

Missed-end rollover plus a mid-run tool gate forced two unplanned recoveries; checklist the skill could state.

**What happened:** `start` found the prior live page with no close marker, so the full `end` flow ran first. The page
the user had edited in the browser carried user-ticked spans that had to be preserved through the close. Separately, a
browser-close and a calendar read issued in the same response were each rejected by the auto-mode gate ("another call
in this response was changed") and succeeded only when re-issued alone.

**Root cause:** The skill describes the rollover but not the cheap sequencing: check the close marker, derive the
snapshot path from the page date, count user-ticked spans, then scrub and mark. Parallel tool calls that include a
hook-rewritten call can invalidate the classifier's review of their siblings (unverified — inferred from symptom).

**Suggested fix:** Add a short rollover checklist (marker check, ticked-span count, snapshot, registry, brag log, scrub
note, marker, commit). Note that a state-changing or hook-touched call should be issued in its own response, and that
a clipboard-click verification of the standup copy button needs a real browser click, so state when it was skipped.
