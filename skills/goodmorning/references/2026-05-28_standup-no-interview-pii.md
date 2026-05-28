---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_standup-no-interview-pii.md
severity: high
---

- **Rule:** Render interview/hiring items in the standup generically (e.g., "L4 SE candidate interview 12pm") with no candidate name, CodeSignal/Greenhouse/scorecard URL, or any hiring-pipeline PII.
- **Why:** Today's Priorities mapped interviews directly to standup bullets without redacting confidential pipeline details.
- **Where:** Step 2d → Apply wk-slack's privacy filter (subsumes the interview-PII case); canonical rules in `wk-slack §Standup Snippet → Standup privacy filter`.
