---
skill: wk-pr-resolve
date: 2026-06-01
type: gap
severity: high
---

After autosquash rebase, detect diverged remote and prefer cherry-pick over force-push.

**What happened:** An autosquash rebase (to fix a file-mode error in a prior commit) rewrote
history on a branch that had already been pushed. This produced a 2-ahead/3-behind diverged
state. The skill had no guard to detect this before proceeding toward a push step.

**Root cause:** `wk-pr-resolve` Step 2 (sync branch) checks for divergence between local
and remote PR branch, but does not check again after history-rewriting operations performed
during the resolution session. A fixup commit followed by `git rebase --autosquash` rewrites
the local branch, invalidating the earlier sync check.

**Suggested fix:** After any history-rewriting operation within the resolution session
(autosquash rebase, amend, fixup), re-run the divergence check from Step 2:
`git rev-list --left-right --count origin/{head_branch}...HEAD`. If the local branch is
both ahead AND behind (non-zero on both sides), the remote has additional commits the
rebase dropped — recover via cherry-pick of the new commits onto the remote tip, rather
than attempting a force-push. Add an explicit guard before the Step 8 push: if diverged,
abort and recover via cherry-pick.
