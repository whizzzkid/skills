---
skill: wk-shell
date: 2026-07-29
type: surprise
severity: medium
verified-against-source: yes
---

Avoid `path` as a zsh loop or script variable because it is tied to `PATH`.

**What happened:** A validation loop bound a file name to `path`. Commands later in the same zsh
process failed with `command not found` until the process ended.

**Root cause:** In zsh, lowercase `path` is a special array tied to uppercase `PATH`; assigning a
scalar loop value replaces the executable search path.

**Suggested fix:** Add `path` to the shell skill's reserved-variable guidance and use role-specific
names such as `doc_path`, `source_path`, or `target_path`.
