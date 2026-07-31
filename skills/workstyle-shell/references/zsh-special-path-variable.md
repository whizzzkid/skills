---
class: principle
date: 2026-07-29
severity: medium
---

# Reserve zsh's lowercase path variable

**Rule:** Never bind lowercase `path` as a zsh loop or script variable. Use a
role-specific name such as `doc_path`, `source_path`, or `target_path`.

**Why:** zsh defines `path` as a special array tied to uppercase `PATH`.
Assigning a scalar file name therefore replaces the executable search path, and
later commands in the same process fail with `command not found`.

**Where:** zsh and portable shell snippets, including ad-hoc validation loops.
