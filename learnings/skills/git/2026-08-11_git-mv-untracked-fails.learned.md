---
skill: wk-git
date: 2026-08-11
type: surprise
severity: low
verified-against-source: yes
---

`git mv` fails on untracked (new, never-committed) files

**What happened:** Attempted `git mv` to rename a newly created spec file that had
never been staged or committed. Git returned `fatal: not under version control`.

**Root cause:** `git mv` requires the source file to be tracked (staged or committed).
New files that have only been written to disk but never `git add`-ed are untracked
and cannot be `git mv`-ed. Confirmed by the error message and successful fallback to
plain `mv` followed by `git add`.

**Suggested fix:** Before using `git mv`, check whether the file is tracked
(`git ls-files --error-unmatch <path>`). For untracked files, use plain `mv` then
`git add` the new path.
