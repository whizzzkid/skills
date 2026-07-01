---
skill: wk-adversarial-review
date: 2026-07-01
type: gap
severity: medium
---

Mechanical sweep catalog under-covers bash string/array quoting and command-argument construction.

**What happened:** Three separate shell-safety bugs landed in one hand-authored pre-commit bash hook and only the fresh adversarial subagent caught them — none was flagged by a mechanical sweep row. The bugs: (1) `grep ... || true | sed` where `|` binds tighter than `||`, making the `sed` stage dead code; (2) `tput` under `set -e` aborting the success branch when `$TERM` is unset/dumb; (3) building `--ignore=` flags as a single string via `echo "$files" | xargs -I{} echo --ignore={}` then re-expanding it unquoted, which word-splits any path containing a space.

**Root cause:** The sweep catalog has shell rows for specific shapes (2.24 missing `--` before expanded args, 2.26 command-capture promotion) but no row for the recurring class of "string/array built then re-expanded unquoted" or "external command under `set -e`/`set -u` whose failure/empty-expansion aborts the script."

**Suggested fix:** Add sweep rows to catch, in any diff touching a shell script: (a) a list of flags/args built as a whitespace-joined string (esp. via `echo | xargs`) and later expanded unquoted — should be a bash array expanded as `${arr[@]+"${arr[@]}"}`; (b) `||`-vs-`|` precedence where a `|| true` guard unintentionally groups with a following pipe stage; (c) external commands (`tput`, etc.) on a success path under `set -e` lacking `2>/dev/null || true`. All three recur in hand-authored hooks.
