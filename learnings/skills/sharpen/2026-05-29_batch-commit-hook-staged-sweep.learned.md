---
skill: wk-sharpen
date: 2026-05-29
type: correction
severity: medium
---

Hook-blocked batch commits leave staged files that bleed into the next per-skill commit.

**What happened:** A pre-commit hook (check-readme) blocked a per-skill commit, leaving its files staged. The next per-skill `git add` + `git commit` swept the previously-staged files in too, merging two skills' changes into one commit and breaking the one-commit-per-skill grouping. A separate check-skill-links hook also fired when a new README.md used bare `wk-*` skill names instead of relative markdown links.

**Root cause:** Step 8 does not guard against residual staged state after a failed commit. When a hook blocks, `git commit` exits non-zero but leaves the index unchanged — the staged set persists invisibly into the next iteration.

**Suggested fix:** After any hook-blocked `git commit` in the batch loop, run `git status --short` before proceeding. If files are still staged, either fix the block and retry that exact commit first, or `git restore --staged <those-files>` before staging the next skill's group. Additionally, when authoring a new sibling README.md, write all `wk-*` mentions as relative links (`[wk-foo](../foo/README.md)`) from the first draft to avoid a check-skill-links bounce.
