---
skill: wk-slack
date: 2026-05-25
type: correction
severity: medium
---

Slack mrkdwn formatting differs from standard Markdown — using standard Markdown produces visible asterisks and broken rendering.

**What happened:** Posted a message using standard Markdown conventions (`**bold**`, numbered list with bold sub-items). The message rendered incorrectly in Slack — bold markers appeared as literal asterisks.

**Root cause:** Slack uses its own "mrkdwn" dialect, not CommonMark. The `slack_send_message` tool description claims standard Markdown support, but in practice Slack renders its own format. Key differences:
- Bold: `*text*` (single asterisk), not `**text**`
- Italic: `_text_`
- Strikethrough: `~text~`, not `~~text~~`
- Links: `<url|label>` for labeled links
- Bullet lists: `•` or `-` work; nested indentation is unreliable
- Headers: not supported — use bold lines instead
- Do not use `**` anywhere; it will render as literal `**`

**Suggested fix:** wk-slack should include a formatting reference section. Before composing any message, convert standard Markdown to mrkdwn: replace `**...**` → `*...*`, `~~...~~` → `~...~`, `[label](url)` → `<url|label>`. Draft the message with mrkdwn from the start rather than writing Markdown and hoping the tool converts it.
