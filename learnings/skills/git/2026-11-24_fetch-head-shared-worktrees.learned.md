---
skill: wk-git
date: 2026-11-24
type: correction
severity: medium
verified-against-source: yes
---

FETCH_HEAD is shared across linked worktrees; never branch from it.

**What happened:** `git fetch origin main` followed by `git switch -c <branch> FETCH_HEAD` created the branch from an
older commit fetched by a different worktree, so the new branch was missing recent main commits.

**Root cause:** Linked worktrees share the common git dir, and FETCH_HEAD lives there; a concurrent fetch in another
worktree overwrites it. `git cat-file -p FETCH_HEAD` showed a commit unrelated to the fetch just run.

**Suggested fix:** Always branch from the remote-tracking ref (`git switch -c <branch> origin/<default>`) after a
fetch, and verify with `git log -1 origin/<default>`.
