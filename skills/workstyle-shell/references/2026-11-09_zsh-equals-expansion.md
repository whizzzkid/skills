---
class: principle
---

# Quote literals that start with `=` in zsh

**Rule** — In any command the agent composes, quote a literal word beginning with `=` (output separators like `===`
included) or pick a separator that does not start with `=`.

**Why** — zsh's `EQUALS` option (default on) expands an unquoted `=word` to the path of command `word`. `echo ===`
looks up a command named `==` and fails with `== not found`, aborting the compound command and skipping every later
step. Reproduced during this fold: an unquoted `=====` separator aborted a read-only chain mid-way. Bash treats the
word literally, so a bash-only review never catches it.

**Where** — `skills/workstyle-shell/SKILL.md` → Zsh/bash portability bullet; `references/zsh-bash-portability.md`.
