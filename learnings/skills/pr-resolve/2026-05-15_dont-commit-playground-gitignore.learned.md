---
skill: wk-pr-resolve
date: 2026-05-15
type: correction
severity: medium
---

Never commit skill scratch directories to the repo's .gitignore

**What happened:** wk-adversarial-review (invoked from Step 8 gate) created .review-playground/ and committed a .gitignore entry to the branch, adding an unrelated commit to the PR.

**Root cause:** The adversarial-review skill's gitignore step was not scoped as local-only; the agent committed it to the repo.

**Suggested fix:** After invoking wk-adversarial-review, verify git status shows no .gitignore modification before proceeding to push. Skill scratch directories must never appear as committed changes in the branch under review.
