---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

Slack mrkdwn angle brackets in a pre/div block must be HTML-encoded or the clipboard copy loses the links.

**What happened:** The standup div contained literal `<url|text>` Slack mrkdwn. The browser parsed the angle brackets as HTML tags and stripped them, so `textContent` and the clipboard copy both lost the links entirely.

**Root cause:** When writing Slack mrkdwn `<url|text>` into an HTML element and reading it back with `textContent` for clipboard, angle brackets must be written as `&lt;` and `&gt;`. The generator wrote raw `<` `>` instead.

**Suggested fix:** When emitting the standup-box div in morning.html, always HTML-encode `<` as `&lt;` and `>` as `&gt;` within the text content. The browser renders them visually as `<` `>` while `textContent` returns the literal characters — exactly what Slack expects for mrkdwn links.
