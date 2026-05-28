---
class: principle
date: 2026-05-28
source: learnings/skills/slack/2026-05-28_slack-message-formatting.md
severity: high
---

- **Rule:** Slack has three distinct formatting contexts (API mrkdwn, plain-text compose paste, dashboard `ClipboardItem` `text/html`); pick the right one before writing — mixing them silently breaks links.
- **Why:** `<url|label>` only renders via the API; in the compose box it pastes as literal angle brackets. `text/html` is the only way to get clickable labels + nested bullets via a dashboard copy button — `textContent`-only copies strip every link.
- **Where:** Step 3a — Pick the right formatting context (Contexts A/B/C with required syntax + failure mode for each).
