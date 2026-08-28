---
skill: wk-git
date: 2026-08-28
type: correction
severity: low
verified-against-source: yes
---

`git merge --continue` does not accept `--no-edit` — use `GIT_EDITOR=true git merge --continue`.

**What happened:** After resolving a merge conflict, `git merge --continue --no-edit` errored (git printed option help instead of committing); the merge stayed uncommitted.

**Root cause:** `--no-edit` is an option of `git merge` at merge start, not of the `--continue` resume path, which always tries to open an editor.

**Suggested fix:** In non-interactive flows, complete conflicted merges with `GIT_EDITOR=true git merge --continue` (or `git commit --no-edit`), never `git merge --continue --no-edit`.
