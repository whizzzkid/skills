---
skill: wk-workflow
date: 2026-05-01
type: correction
severity: medium
---

Diff commands must use the PR's base branch, not a hardcoded branch name

**What happened:** The code-review step instructed the reviewer agent to operate on `git diff main...HEAD`, hardcoding `main` as the base. In PR stacks, the base is the parent branch, not main.

**Root cause:** Branch name was written literally instead of resolved dynamically from the PR's `baseRefName`.

**Suggested fix:** Replace hardcoded base branch names in diff commands with a dynamic lookup: `gh pr view --json baseRefName --jq .baseRefName` or use `$(git merge-base HEAD origin/$(gh pr view --json baseRefName --jq .baseRefName))`. Any skill that describes a diff operation against a base branch should use the PR's actual base, not assume `main` or `master`.
