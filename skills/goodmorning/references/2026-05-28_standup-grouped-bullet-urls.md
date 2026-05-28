---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_standup-merged-prs-missing-urls.md
severity: medium
---

- **Rule:** Grouped standup bullets (e.g., "Merged 4 PRs: …") require one bare URL per artifact, space-separated on the same line — not one URL for the group.
- **Why:** The per-bullet URL check is satisfied at the artifact level; one URL for N PRs leaves N-1 artifacts unlinked and breaks Slack-paste traceability.
- **Where:** Standup snippet → Source-link enforcement (HARD RULE for grouped bullets).
