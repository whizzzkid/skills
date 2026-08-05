---
skill: wk-gh
date: 2026-08-04
type: correction
severity: low
verified-against-source: yes
---

Quote REST paths containing query strings when invoking `gh api` from zsh.

**What happened:** An unquoted contents endpoint ending in `?ref=main` was expanded by zsh and failed with
`no matches found` before `gh` ran. Quoting the complete endpoint made the same request succeed.

**Root cause:** zsh treats `?` as a glob metacharacter when the REST path is unquoted.

**Suggested fix:** Add a `wk-gh` command-construction rule requiring the complete `gh api` endpoint to be quoted when
it contains `?`, `&`, `*`, or other shell metacharacters.
