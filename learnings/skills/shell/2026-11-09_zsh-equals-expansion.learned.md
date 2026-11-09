---
skill: wk-shell
date: 2026-11-09
type: surprise
severity: low
verified-against-source: n/a
---

In zsh, a bare `===` word (e.g. `echo ===` as an output separator) triggers `=cmd` expansion and fails with "== not found".

**What happened:** A chained read-only command aborted mid-way because an unquoted `===` separator was expanded.

**Root cause:** zsh EQUALS option expands words starting with `=` to command paths.

**Suggested fix:** Quote separators (`echo '----'`) in compound commands.
