---
skill: wk-workstyle-shell
date: 2026-10-16
type: correction
severity: medium
verified-against-source: n/a
---

Never name a shell variable `path` in zsh: it is tied to `$PATH`.

**What happened:** An ad-hoc loop assigned `path=$(...)` per iteration; zsh's lowercase `path` array is tied to
`PATH`, so the assignment replaced the search path and every subsequent command in the loop failed with
"command not found".

**Root cause:** zsh special parameters (`path`, `cdpath`, `fpath`, `manpath`, `module_path`) mirror their uppercase
colon-separated counterparts; the agent's interactive shell is zsh even when the snippet is written as bash.

**Suggested fix:** Add to the shell workstyle rules: avoid zsh-tied names (`path`, `cdpath`, `fpath`, `manpath`) for
variables; for non-trivial loops, write a `#!/usr/bin/env bash` script file and run it with `bash` so the semantics
are bash's, not the login shell's.
