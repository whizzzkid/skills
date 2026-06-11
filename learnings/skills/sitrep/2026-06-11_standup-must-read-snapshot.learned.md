---
skill: wk-sitrep
date: 2026-06-11
type: correction
severity: high
---

Standup snippet must be built from yesterday's snapshot.md, not from session memory.

**What happened:** The `start` sub-command generated the standup "Yesterday" section from a high-level session-memory summary, missing the full list of PRs opened/merged that were documented in the prior day's snapshot.

**Root cause:** Stage 1 reads `live.md` for carry-overs but never reads the previous day's `snapshot.md`. The standup compilation step defaulted to session memory when the snapshot file was not explicitly loaded, silently producing an incomplete Yesterday list.

**Suggested fix:** Add an explicit read of `$PREV_SNAPSHOT_FILE` (`$SITREP_REPO/$EMPLOYER/<YYYY>/<MM>/<DD>/snapshot.md` for the previous working day) at the end of Stage 1, before any standup compilation. Extract `## Achievements / ### Code & PRs` as the primary Yesterday source. Only fall back to session memory when the snapshot file is absent.
