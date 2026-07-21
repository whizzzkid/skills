---
class: principle
---

**Rule** — Post-merge state verification (`gh pr view`, `gh pr checks`) needs
standing `Bash(gh pr view:*)` / `Bash(gh pr checks:*)` allow rules, and each must
run as a standalone invocation. A pipe to `grep`/`jq` or a compound (`&&`,
`cmd && gh pr view`) re-triggers the auto-mode classifier and blocks the call. Do
filtering in a separate step. (`--jq` is a `gh` flag, not a pipe — still matches.)

**Why** — An allow rule matches only when the allowed command is the whole
invocation. Compound/piped commands are not the allowed command, so the classifier
re-evaluates and can stall Step 6 confirmation and the downstream steps.

**Where** — wk-pr-merge Step 6 permission HARD RULE.
