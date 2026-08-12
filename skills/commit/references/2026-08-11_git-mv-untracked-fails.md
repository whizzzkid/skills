---
class: one-off
date: 2026-08-11
skill: wk-commit
---

# git mv fails on untracked (new, never-committed) files

- **Scenario:** Attempted `git mv` to rename a newly created spec file that had
  never been staged or committed. Git returned `fatal: not under version control`.
- **Symptom:** `git mv` requires the source file to be tracked. New files only on
  disk are untracked and cannot be moved with `git mv`.
- **Fix:** Check tracking status first (`git ls-files --error-unmatch <path>`).
  For untracked files, use plain `mv` then `git add` the new path.
- **Why not promoted:** The sharpen skill already says "use plain `mv`, never
  `git mv`, and check rc" for learning renames. Broader use of `git mv` is rare
  enough for a one-off note.
