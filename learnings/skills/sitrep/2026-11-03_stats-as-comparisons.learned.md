---
skill: wk-sitrep
date: 2026-11-03
type: pattern
severity: medium
verified-against-source: n/a
---

Present performance stats as rank and ratio vs team average; keep peer-level exports out of git.

**What happened:** A developer-analytics CSV gave per-person metrics for the whole team. The user wanted "most on the
team, ~2.4x average" rather than raw counts. The analytics MCP had no permissions, so a user export was the only path.

**Root cause:** Raw counts read as activity-justifying; peers' figures are sensitive.

**Suggested fix:** Compute ratio vs team average and rank, quote only the user's own figures, and gitignore
per-person export files (they contain teammates' names, emails and metrics). Any org-wide superlative not backed by a
source must be flagged to the user as unverified.
