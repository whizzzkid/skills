---
skill: wk-slack
date: 2026-05-28
type: gap
severity: high
---

Slack message formatting has three distinct contexts with incompatible syntax; using the wrong one silently breaks links.

**What happened:** A standup snippet used bare URLs (correct for plain-text paste), then Slack mrkdwn `<url|text>` syntax (only works via API, breaks in compose box), then raw HTML (stripped by browser textContent) before landing on the correct approach.

**Root cause:** The skill did not document the three contexts and their required formats:

1. **Slack API / Bot messages** — use Slack mrkdwn: `<url|text>`, `*bold*`, `_italic_`, bullet with `-`. Never use HTML.
2. **Typed or pasted into compose box** — bare URLs auto-linkify. Mrkdwn `*bold*` works. `<url|text>` does NOT render. Use plain text with bare URLs for links.
3. **Copy-to-clipboard from a web dashboard pasting into compose box** — must use `ClipboardItem` with `text/html` containing real `<a>` tags and `<ul><li>` nesting. `textContent` strips tags. Slack's desktop app respects `text/html` on paste and renders links + bullets correctly.

**Suggested fix:** Add a "Formatting Contexts" reference section to wk-slack documenting all three contexts, their compatible syntax, and the failure mode of each wrong choice. Default to context 3 (ClipboardItem + text/html) whenever generating a dashboard copy button.
