---
class: principle
---

# Apply zsh reserved-variable checks to compound commands

**Rule** — Apply reserved-variable checks to every compound ad-hoc zsh command, not only committed scripts. Use
role-specific loop names; never assign lowercase `path`.

**Why** — In zsh, scalar assignment to `path` replaces the executable search path for later commands in the group.

**Where** — Invocation trigger and zsh portability traps.
