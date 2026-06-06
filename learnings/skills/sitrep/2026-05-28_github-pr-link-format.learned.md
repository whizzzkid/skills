---
skill: wk-goodmorning
date: 2026-05-28
type: correction
severity: low
---

GitHub PR links must always be labeled as `repo#number`, never bare `#number`.

**What happened:** Standup snippet rendered PR links as `<a href="...">#156</a>` with just the number as the label, losing repo context when pasted into Slack.

**Root cause:** When grouping multiple PRs from the same repo, the generator dropped the repo prefix to save space, producing ambiguous bare `#NNN` links.

**Suggested fix:** All GitHub PR links anywhere in the brief must use the format `<a href="url">repo#number</a>` (e.g. `{repo}#NNN`, `claude-code#NNN`). Never use bare `#NNN` as link text — the repo name is required for context, especially when pasted outside the brief.
