---
class: principle
skill: wk-learn
date: 2026-07-24
severity: low
---

- **Rule:** A newly written learning is left **untracked** — never `git add`ed. The
  distillation pass is what renames it to the processed suffix and commits it. State
  the untracked-until-distilled invariant wherever the skill validates the filename,
  and repeat it in the completion signal so a later "clean tree" check does not read
  the file as leftover debris.
- **Why:** The repo deliberately keeps undistilled learnings out of history: the
  pre-commit filename hook accepts only the processed suffix and reports that a plain
  `.md` is unprocessed. Guidance that mentions `git add` in the same breath as
  filename validation reads as an instruction to stage the file, producing a blocked
  commit and a wasted unstage cycle. It also mis-trains downstream "tree must be
  empty" gates into deleting valid pending work.
- **Where:** Step 3 filename-validation paragraph (promoted to a HARD RULE, dropped
  `git add` from the sentence, added the unstage remedy) and Step 4's signal
  paragraph (untracked = expected state). The consuming skill's terminal clean-tree
  gate was narrowed to *modified tracked* paths in the same pass.
