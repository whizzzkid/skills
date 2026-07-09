---
class: principle
---

**Rule** — In the terminal worktree-cleanup step, remove the just-merged
worktree directly with the `git wtr <name>` alias (`git worktree remove
worktrees/<name>` + `git branch -D <name>`) instead of delegating to a
generic worktree-cleanup skill. Chdir to the main worktree first — `git
worktree remove` refuses the worktree it is run from. Skip entirely when the
merge ran from the repo root.

**Why** — After a confirmed merge (`state == "MERGED"`) the branch-merged
safety check that a generic cleanup skill performs is redundant; a one-shot
alias is faster and the remote branch was already deleted by the merge's
`--delete-branch`. The chdir is mandatory because git will not remove the
current working tree.

**Where** — `pr-merge` Step 10.
