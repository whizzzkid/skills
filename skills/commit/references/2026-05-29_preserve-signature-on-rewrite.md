---
class: principle
date: 2026-05-29
skill: wk-commit
---

**Rule:** Re-sign every commit a history rewrite touches; verify signatures survive.

**Why:** Rebase/amend/cherry-pick/squash re-create commits and drop the original signature unless re-signed — an unsigned rewritten commit loses verified status and can fail signed-commit branch protection.

**Where:** `### Preserve signatures when rewriting history` sub-section under Commit Signing.
