---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

wk-goodmorning must delegate all Slack-destined message formatting to wk-slack rather than implementing it inline.

**What happened:** wk-goodmorning implemented its own standup formatting logic, independently discovering (through repeated user corrections) rules that wk-slack already owns: nested bullet structure, one link per bullet, ClipboardItem text/html, repo#number PR labels, and the three Slack formatting contexts.

**Root cause:** wk-goodmorning has its own "Standup Snippet" section that specifies format independently of wk-slack. This created a duplicate, out-of-sync specification that lacked the full formatting knowledge in wk-slack.

**Suggested fix:** Remove the inline standup HTML spec from wk-goodmorning's standup section and replace it with: "Invoke wk-slack §Standup Snippet to generate the standup card content and copy button. wk-slack owns the format spec, clipboard behavior, privacy filter, and structural rules." This keeps formatting logic in one place and ensures any wk-slack improvement automatically benefits the morning brief.
