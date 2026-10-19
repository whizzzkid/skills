---
class: principle
---

# Re-violation: zsh-tied variable names clobber the search path

**Rule** — never name a shell variable `path`, `cdpath`, `fpath`, `manpath`, or `module_path`; zsh ties each to its
uppercase colon-separated twin. Non-trivial loops go in a `bash` script file run with `bash`, so bash semantics apply
regardless of the login shell.

**Why** — an ad-hoc loop assigned `path=$(...)` per iteration under zsh, replacing `PATH`; every later command in the
loop failed `command not found`. The rule already existed (reference-only, baseline prose) and was missed, so it is
escalated one rung to `**Important:**` and surfaced inline in `SKILL.md`, widened from `path` to the whole tied family.

**Where** — `SKILL.md` → Rules → zsh/bash portability sub-bullet; `references/zsh-bash-portability.md` reserved-variable
trap. Escalation: baseline → `**Important:**`.
