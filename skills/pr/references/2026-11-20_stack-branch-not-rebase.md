---
class: principle
skill: wk-pr
date: 2026-11-20
---

# Stack a new branch on an open PR by branching from its head

- **Rule:** To stack a fresh task branch on an open PR, run `git switch -c <new-branch> origin/<pr-branch>`, then
  `git branch --unset-upstream`. Never `git rebase origin/<pr-branch>` to get there.
- **Why:** A rebase replays every commit that is not in the target, including default-branch commits the parent PR
  has not merged yet. A task branch with no commits of its own, sitting on a newer default-branch commit, had that
  commit replayed into the stacked diff, and the `git reset --hard` cleanup was then blocked as destructive.
  Unsetting the upstream stops a bare `git push` from landing on the parent PR's branch.
- **Where:** `SKILL.md` → Stacking. Logged against a non-existent `wk-git` skill; routed to `wk-pr`, which owns
  stacking. Source: git learning and the 2026-11-21 session-1 retrospect.
