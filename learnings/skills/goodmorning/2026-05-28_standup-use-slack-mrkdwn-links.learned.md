---
skill: wk-goodmorning
date: 2026-05-28
type: correction
severity: medium
---

Standup snippet should use Slack mrkdwn inline links, not bare URLs.

**What happened:** The skill's HARD RULE says "bare URLs only" because markdown `[text](url)` doesn't paste correctly into Slack. The standup was generated with bare URLs. User asked for inline linked text instead.

**Root cause:** The skill conflates two different formats — markdown `[text](url)` (broken in Slack) and Slack's own mrkdwn `<url|text>` (renders correctly as linked text when pasted). The HARD RULE only needed to ban markdown links, not all inline linking.

**Suggested fix:** Update the HARD RULE to: "Use Slack mrkdwn format `<url|text>` for all links — never markdown `[text](url)`. Slack mrkdwn links render as clickable inline text when pasted and are the preferred format." Update the HTML clipboard payload and the markdown standup section to emit `<url|text>` syntax instead of bare URLs.
