---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_html-encode-slack-mrkdwn-in-div.md
severity: medium
---

- **Rule:** HTML-encode `<` and `>` (`&lt;`, `&gt;`) wherever Slack mrkdwn `<url|text>` appears inside HTML; build the clipboard payload from the encoded element's `textContent`.
- **Why:** Raw angle brackets are parsed as HTML tags and stripped from both the rendered DOM and `textContent` — silently destroying every Slack link in the clipboard copy.
- **Where:** Standup snippet → HTML rendering bullets (HARD RULE on entity encoding + clipboard-source rule).
