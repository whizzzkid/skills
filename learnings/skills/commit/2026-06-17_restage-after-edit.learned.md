---
skill: wk-commit
date: 2026-06-17
type: gap
severity: medium
---

After editing an already-staged file, re-run `git add <file>` before committing — the index is a snapshot, not a live mirror.

**What happened:** The pre-commit hook (RuboCop) inspected the staged version of files and reported offenses that were already fixed in the working tree. The edits had been applied via Edit tool but `git add` was not re-run, so the index still held the pre-fix content. The commit was blocked, requiring an extra fix-and-restage cycle.

**Root cause:** `git add` takes a snapshot of the working tree at the moment it is called. Subsequent edits to that file update the working tree but leave the staged snapshot untouched. The pre-commit hook inspects the staged content (what will actually be committed), not the working tree.

**Suggested fix:** Add a step to `wk-commit`: after any Edit/Write tool call on a file that is already staged (`git diff --cached --name-only` lists it), re-run `git add <file>` immediately. Alternatively, add a pre-commit checklist item: "are there working-tree changes to staged files? (`git diff --name-only` vs `git diff --cached --name-only` overlap → re-stage)."
