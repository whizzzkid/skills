---
skill: wk-workflow
date: 2026-08-13
type: gap
severity: low
verified-against-source: yes
---

Agents writing code comments with non-ASCII characters fail RuboCop Style/AsciiComments

**What happened:** Worktree-isolated agents wrote route comments containing em
dashes (U+2014). CI RuboCop flagged Style/AsciiComments, requiring a follow-up
lint fix commit from the coordinator.

**Root cause:** Agents were not instructed to use ASCII-only characters in code
comments, and could not run rubocop themselves due to the Bash isolation blocker.

**Suggested fix:** Add a note to the worktree-agent dispatch instructions or the
wk-workstyle-docs skill: code comments must use ASCII only (double-dash instead
of em dash, etc.) to satisfy common linter rules. When agents cannot lint, the
coordinator should run rubocop before committing agent work.
