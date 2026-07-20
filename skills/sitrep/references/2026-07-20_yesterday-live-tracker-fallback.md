---
class: principle
skill: sitrep
date: 2026-07-20
---

**Rule** — a fallback chain built only from prior-run artifacts (snapshot →
session memory) fails when the prior run never happened. When the derived state
exists in live systems of record, add a terminal tier that reconstructs it
directly — author-scoped, date-ranged queries — rather than reporting nothing.

**Why** — consecutive days that ran `start` but never `end` leave no snapshot,
and session memory only records what a session did, not what a skipped `end`
would have captured. Both primary sources are empty, yielding an empty
"Yesterday" unless the agent falls through to GitHub merged-PR and Jira
transitioned-to-Done searches for the date range.

**Where** — Stage 4b "Yesterday": fallback chain is snapshot → session memory →
live-tracker reconstruction; Stage 1 cross-refs it. Reuses the canonical
Authorship filter (never trust carryover/agent attribution).
