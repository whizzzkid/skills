---
class: principle
---

**Rule:** When the Jira MCP connector is unavailable or unauthenticated, do not
block the merge. Surface the detected key and its terminal state in the
follow-ups output for manual transition, mirroring the Asana fallback.

**Why:** The merge event owns the ticket transition, but an MCP auth gap must not
abort a clean merge. A silent skip leaves the ticket stranded; a surfaced manual
instruction keeps the human in the loop.

**Where:** wk-pr-merge Step 7 — Jira tickets section, after the terminal-transition
lookup.
