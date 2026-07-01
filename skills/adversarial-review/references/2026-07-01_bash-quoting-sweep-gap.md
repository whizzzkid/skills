---
class: principle
---

**Rule** — Any diff touching a shell script must sweep three recurring quoting/precedence gaps the symbol sweeps miss: (a) a flag/arg list built as a whitespace-joined string (esp. `echo "$x" | xargs -I{} echo --flag={}`) and re-expanded unquoted → word-splits paths with spaces; use a bash array `${arr[@]+"${arr[@]}"}`. (b) `|| true` immediately followed by a pipe — `|` binds tighter than `||`, so the post-pipe stage is dead code; parenthesize the guarded command. (c) an external command (`tput`, etc.) on a success path under `set -e` aborts on failure or unset/dumb `$TERM` → needs `2>/dev/null || true`.

**Why** — Three shell-safety bugs of exactly these shapes landed in one hand-authored pre-commit hook; only the fresh adversarial subagent caught them. The catalog had specific shell rows (missing `--`, command-capture promotion) but no row for joined-string-arg re-expansion, `||`/`|` precedence, or success-path external commands under `set -e`.

**Where** — `wk-adversarial-review` sweep 2.63 (extended catalog).
