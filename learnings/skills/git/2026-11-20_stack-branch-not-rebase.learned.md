---
skill: wk-git
date: 2026-11-20
type: correction
severity: medium
verified-against-source: n/a
---

To stack a fresh task branch on an open PR, branch from the PR head; do not rebase onto it.

**What happened:** The task branch had no commits of its own, but it sat on a newer default-branch commit that the
parent PR branch did not contain. `git rebase origin/<pr-branch>` replayed that commit as a new one, so the stacked
diff now carried unrelated base work. Auto mode then blocked `git reset --hard` as destructive.

**Root cause:** A rebase replays every commit that is not in the target branch, and that includes base-branch commits
the parent PR has not merged yet.

**Suggested fix:** When stacking, run `git switch -c <new-branch> origin/<pr-branch>`, then
`git branch --unset-upstream`. The second command stops a bare `git push` from going to the parent PR's branch.
