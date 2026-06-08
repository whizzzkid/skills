---
skill: wk-silverbullet
date: 2026-06-08
type: surprise
severity: medium
---

SilverBullet renders inline markdown (`**bold**`, `[link](url)`, emoji) inside HTML blocks but NOT block-level markdown (`- [ ]` lists, headings).

**What happened:** Inside no-blank-line HTML blocks, `**bold**` rendered as `<strong>`, `[text](url)` rendered as `<a href>` clickable links, and emojis rendered normally. However, `- [ ]` task list items rendered as literal `- [ ]` text.

**Root cause:** SilverBullet's HTML widget processes the raw HTML through its renderer which applies inline markdown span-level formatting. Block-level constructs (task lists, ATX headings, fenced code) are not processed within HTML block context.

**Suggested fix:** Write content for HTML column blocks using inline markdown freely (bold, links, inline code, emojis). Do not rely on block-level markdown constructs (lists, headings, task items) — they render as literal text. Use HTML equivalents (`<strong>`, `<a>`) or design around the limitation.
