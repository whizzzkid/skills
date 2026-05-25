---
class: principle
date: 2026-05-25
source: learnings/skills/slack/2026-05-25_markdown-formatting-mismatch.md
---

- **Rule:** Always write Slack messages in mrkdwn, never standard Markdown. `**bold**` → `*bold*`, `~~strike~~` → `~strike~`, `[label](url)` → `<url|label>`. Draft in mrkdwn from the start; do not write Markdown and hope the tool converts it.
- **Why:** Slack renders `mrkdwn`, not CommonMark. `**bold**` displays as literal asterisks; `[label](url)` displays as literal brackets. The `slack_send_message` tool description claims Markdown support but Slack does not honour it.
- **Where:** Step 3 formatting rules table and Common Mistakes section.
