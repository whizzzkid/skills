---
skill: wk-sharpen
date: 2026-06-08
type: gap
severity: low
---

`.learned.md` rename staging fails when the source learning was never tracked.

**What happened:** In the Step 8 chore commit, `git add` listed both the old
`<slug>.md` and the new `<slug>.learned.md` paths. The old paths no longer
existed on disk (the `mv` had already moved them) and were never tracked in
git, so `git add` aborted with `fatal: pathspec ... did not match any files`
and staged nothing. Re-running with only the new `.learned.md` paths + the log
succeeded.

**Root cause:** Step 8 assumes `mv "$file" "${file%.md}.learned.md"` produces a
tracked rename (old-path deletion + new-path add). When the learning was an
untracked file (e.g., freshly mirrored from the global inbox, or never
committed), there is no deletion to stage — only a new untracked file. Adding
the non-existent old path makes the whole `git add` fail.

**Suggested fix:** In Step 8, stage `.learned.md` renames by adding only the
new `.learned.md` paths (plus `.distilled-sources.log`); never enumerate the
pre-rename `.md` path. `git add` of the new file captures both the add and any
tracked-deletion side when one exists, and does not abort when the source was
untracked.
