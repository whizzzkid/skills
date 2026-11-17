---
skill: wk-sitrep
date: 2026-11-16
type: gap
severity: medium
verified-against-source: n/a
---

A dirty-tree stop in the rollover stage ends the run silently from the user's point of view.

**What happened:** `start` stopped on tracked non-artifact edits, reported once, and the user asked why they had not been notified and what the connector gaps were; no gather had run, so there were none to report.

**Root cause:** The stop path has no notification step and the response did not say that connector gaps were unknown because the gather never ran.

**Suggested fix:** On any pre-gather stop, state the exact paths, the options (commit, stash, discard) and that connector status is unchecked; offer a push notification.
