---
skill: wk-pr
date: 2026-08-05
type: correction
severity: medium
verified-against-source: yes
---

Compose Markdown PR bodies with a quoted heredoc delimiter.

**What happened:** An unquoted heredoc evaluated Markdown backticks as shell command substitutions
and posted command output in place of inline code.

**Root cause:** Shell expansion remains active inside an unquoted heredoc; fetching the posted body
confirmed that backtick expressions had executed and their output replaced the intended text.

**Suggested fix:** Require a single-quoted heredoc delimiter for Markdown bodies, then check expected
literal markers and a reasonable body length immediately before and after every PR-body write.
