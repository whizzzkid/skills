---
skill: wk-sitrep
date: 2026-05-28
type: gap
severity: medium
---

wk-sitrep end must delegate Slack-destined message formatting to wk-slack for consistency.

**What happened:** wk-goodmorning's standup formatting diverged from correct Slack paste behavior because each skill implements formatting independently. wk-sitrep end has the same risk — it generates "tomorrow's prep" content and meeting notes that may be shared in Slack, but applies no consistent formatting contract.

**Root cause:** Both wk-goodmorning and wk-sitrep end implement Slack-destined content without delegating to wk-slack, creating independent duplications of formatting logic that can drift.

**Suggested fix:** Any time wk-sitrep end generates content intended for Slack posting (share-outs, standup carry-over, meeting action items), invoke wk-slack for formatting rather than generating raw text. This applies especially to: evening achievements that will appear in tomorrow's standup Yesterday section, and meeting follow-through items that will be posted to channels.
