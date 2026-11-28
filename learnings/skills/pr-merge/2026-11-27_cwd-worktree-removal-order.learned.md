---
skill: wk-pr-merge
date: 2026-11-27
type: surprise
severity: low
verified-against-source: yes
---

Removing the worktree that is the session's working directory breaks any Bash call issued in parallel with it.

**What happened:** In Step 10 the merged worktree was also the session's CWD. Its removal and the local-branch delete
were sent as parallel calls. The removal succeeded, but the harness refused the branch delete, because the shell's
working directory no longer existed. The delete then had to be re-issued from the main checkout.

**Root cause:** Every Bash call starts in the session CWD. Once `git worktree remove` deletes that directory, later
and concurrent calls cannot start there, whatever `-C` path they pass.

**Suggested fix:** In Step 10, when the target worktree is the session CWD, run its cleanup in sequence, never in
parallel: (1) `git -C <main-checkout> worktree remove <path>`; (2) as a separate, later call,
`git -C <main-checkout> branch -D <branch>`. Better still, delete the branch first (it's allowed once the worktree is
removed). Resolve `<main-checkout>` from the first line of `git worktree list` before removing anything.
