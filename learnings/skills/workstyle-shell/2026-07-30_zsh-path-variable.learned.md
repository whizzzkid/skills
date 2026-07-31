---
skill: wk-workstyle-shell
date: 2026-07-30
type: surprise
severity: medium
verified-against-source: yes
---

Do not use lowercase `path` as a zsh loop or script variable.

**What happened:** A read-only link-validation loop assigned each filename to `path`. Subsequent
commands failed with `command not found` because zsh ties the special `path` array to `PATH`.

**Root cause:** In zsh, assigning a scalar value to lowercase `path` replaces the executable search
path. The failure reproduced immediately in the same shell after the assignment.

**Suggested fix:** Add `path` to the shell skill's reserved-variable list alongside `HOME` and use
task-specific names such as `doc_path` or `target_path`.
