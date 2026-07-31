---
skill: wk-pr-merge
date: 2026-07-31
type: gap
severity: medium
verified-against-source: yes
---

Audit the remote head branch when entering the already-merged path.

**What happened:** The merge workflow correctly detected that the pull request
was already merged and skipped the mutation steps, but its remote head branch
still existed even though cleanup assumes the merge step deleted it.

**Root cause:** The already-merged path skips the command that carries
`--delete-branch`, while the cleanup instructions state that the remote branch
was already removed.

**Suggested fix:** In the already-merged path, check for open child pull
requests, retarget any dependents, then delete the remote head branch or
explicitly report why it remains before local worktree cleanup.
