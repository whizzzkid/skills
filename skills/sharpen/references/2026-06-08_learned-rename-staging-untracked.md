---
class: principle
---

- **Rule:** Stage a `.learned.md` rename by adding only the new `.learned.md`
  path (plus the log); never enumerate the pre-rename `.md` path.
- **Why:** When the source learning was untracked, there is no deletion to
  stage, and `git add` of the missing old path aborts the whole staging with
  `fatal: pathspec ... did not match any files`.
- **Where:** Step 8 commit bullet (after the README relative-link bullet).
