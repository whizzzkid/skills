---
class: principle
date: 2026-06-10
severity: high
---

- **Rule:** Before treating a `data-done="false"` item as carry-over at `end`,
  cross-validate it against the Stage 2 agents' data (GitHub merged/closed,
  Jira Done, attended meeting, replied Slack thread) and move confirmed ones to
  done; report detected-done vs user-checked-done separately.
- **Why:** Users action items without toggling the checkbox, so `data-done`
  undercounts completions and silently carries finished work forward.
- **Where:** Sub-command `end`, Stage 3 (cross-validation pass).
