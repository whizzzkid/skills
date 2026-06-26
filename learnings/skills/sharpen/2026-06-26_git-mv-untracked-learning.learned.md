---
skill: wk-sharpen
date: 2026-06-26
type: gap
severity: low
---

Step 8 rename of a fresh learning fails with `git mv` — use plain `mv`.

**What happened:** Renaming a just-written learning to `.learned.md` via `git mv`
aborted: `fatal: not under version control` — the learning file is newly created and
untracked, so git cannot move it.

**Root cause:** `git mv` requires the source to be tracked. A learning written this
same run has never been committed.

**Suggested fix:** Step 8 should rename `.learned.md` with plain `mv` (then `git add`
the new path), not `git mv`. `git mv` only applies to already-tracked files.
