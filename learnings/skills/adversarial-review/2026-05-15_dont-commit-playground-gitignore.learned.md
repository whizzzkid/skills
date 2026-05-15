---
skill: wk-adversarial-review
date: 2026-05-15
type: correction
severity: medium
---

Never commit .review-playground/ to the repo's .gitignore

**What happened:** The skill created .review-playground/ as a local scratch dir and added it to the repo's .gitignore, committing that change to the branch under review.

**Root cause:** The skill instructions say the dir is "gitignored" but don't specify that the gitignore entry must not be committed — the agent treated it as a repo-level change rather than a local-only concern.

**Suggested fix:** Keep .review-playground/ in the user's global gitignore (~/.gitignore_global) or add it once to the repo's .gitignore only if the repo maintainer opts in. Skills must never commit their own scratch directories as repo changes — all skill artifacts are ephemeral and local-only.
