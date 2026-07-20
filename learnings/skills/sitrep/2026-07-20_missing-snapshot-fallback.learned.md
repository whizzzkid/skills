---
skill: wk-sitrep
date: 2026-07-20
type: gap
severity: medium
---

Standup "Yesterday" section has no defined fallback when multiple consecutive days skip the `end` sub-command, leaving no snapshot file to source wins from.

**What happened:** The previous two workdays only ran `start`, never `end` — no `snapshot.md` existed for either day. The skill's Stage 4b instructions assume `## Achievements` from the prior day's snapshot is the primary source and only mention falling back to "session memory" when the file is absent, but session memory itself had no record either (session memory only persists what happened in that session, not what a skipped `end` would have captured). Recovered by cross-checking GitHub for PRs authored and merged in the relevant date range instead.

**Root cause:** The skill's fallback chain (snapshot → session memory) doesn't cover the case where neither source has the data because `end` was never run. It doesn't tell the agent to reconstruct "yesterday" from live trackers (GitHub/Jira merged-since-date searches) when both primary sources are empty.

**Suggested fix:** Add a third fallback tier to Stage 4b: when the previous working day's snapshot is absent AND session memory has no matching entry, reconstruct "Yesterday" wins via an author-scoped, date-ranged search across GitHub (merged PRs) and Jira (transitioned-to-Done tickets) for that specific date, applying the same authorship-verification rule already used elsewhere in the skill.
