---
class: principle
---

**Rule:** After editing a file that is already staged, re-run `git add <file>` before committing.

**Why:** `git add` snapshots the working tree at call time; subsequent edits update the working tree but not the staged snapshot. Pre-commit hooks inspect staged content, so they report offenses already fixed in the working tree and block the commit — forcing an extra fix-and-restage cycle. Detect with `comm -12` over `git diff --name-only` and `git diff --cached --name-only`.

**Where:** "Verify the staged set before a grouped commit" section.
