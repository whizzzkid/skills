---
skill: wk-pr-review
date: 2026-05-15
type: correction
severity: medium
---

Never commit skill scratch directories to the repo's .gitignore

**What happened:** Adversarial-review (invoked from pr-resolve) created a scratch dir and committed a .gitignore entry for it to the branch, polluting the PR with a non-product change.

**Root cause:** Skills treat their scratch directories as repo-managed, but they are ephemeral local artifacts that belong in the user's global gitignore, not the repo's.

**Suggested fix:** When invoking sub-skills that create scratch dirs, verify no .gitignore modification is committed to the branch. Any .gitignore entry for a skill artifact must go to ~/.gitignore_global, not the repo file.
