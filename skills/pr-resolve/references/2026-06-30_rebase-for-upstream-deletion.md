---
class: principle
---

- **Rule:** A clean local merge-into-branch does not clear GitHub's
  `mergeable: CONFLICTING` when upstream deleted a file the branch modified.
  `gh pr view --json mergeable` returns `CONFLICTING` after the merge → pivot to
  `git rebase --onto origin/$BASE $(git merge-base HEAD origin/$BASE) HEAD`; never
  retry a second merge or manual resolution.
- **Why:** GitHub recomputes mergeability from the original PR ancestor, which
  still contains the deleted file, so a merge commit on the tip changes nothing it
  sees. Only rebasing onto the current base gives GitHub a new ancestor.
- **Where:** Step 2 base-advance rebase bullet.
