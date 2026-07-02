---
skill: wk-testing-skeleton
date: 2026-07-02
type: correction
severity: medium
---

A shell-test assertion for a literal tilde-prefixed string silently never matched because bash tilde-expanded the leading `~` inside `[[ =~ ]]`.

**What happened:** A test asserted output contained a tilde-prefixed home path (a yarnrc dotfile) via a `[[ "$output" =~ ~... ]]` regex. The unquoted leading `~` was tilde-expanded to `$HOME` before the regex match, so the pattern became the expanded home path and never matched the literal-tilde output. The assertion passed/failed for the wrong reason.

**Root cause:** Tilde expansion runs on the right-hand side of `=~` before regex evaluation; an unquoted leading `~` becomes `$HOME`, not a literal `~`.

**Suggested fix:** Assert literal-tilde strings with a quoted glob (`[[ "$output" == *'~'* ]]`, quoting any tilde-prefixed path segment), not a regex. When a substring could match a superset (a yarnrc dotfile name also matches its `.yml` sibling), add a negative assertion to exclude the superset.
