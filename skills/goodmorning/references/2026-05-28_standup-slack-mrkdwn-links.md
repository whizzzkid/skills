---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_standup-use-slack-mrkdwn-links.md
severity: medium
---

- **Rule:** Emit standup links as Slack mrkdwn `<url|text>`, not markdown `[text](url)` and not bare URLs when a useful label exists.
- **Why:** Markdown link syntax pastes as literal brackets/parens in Slack; `<url|text>` renders as a clickable label. The previous "bare URLs only" rule conflated two formats and dropped the clickable-label affordance.
- **Where:** Standup snippet → Format block, Source-link enforcement, Grouped-bullet rule, HTML clipboard payload, markdown rendering note.
