---
class: principle
date: 2026-06-11
skill: wk-sitrep
severity: high
---

- **Rule:** Read `$PREV_SNAPSHOT_FILE` at the end of Stage 1; its
  `## Achievements / ### Code & PRs` is the primary source for the standup
  Yesterday section. Fall back to session memory only when the file is
  absent.
- **Why:** Stage 1 read only `live.md`; the standup defaulted to a
  high-level session-memory summary that dropped the full PR list.
- **Where:** start Stage 1 (prev-snapshot read) + Stage 4b (Yesterday
  source).
