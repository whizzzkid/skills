---
skill: wk-workflow
date: 2026-06-10
type: correction
severity: high
---

Always check existing PR's base branch before planning a rebase.

**What happened:** Agent computed `origin/main..HEAD` to understand the branch's commits before a rebase task. The branch had an open PR with a non-default base (`feat/go-resolver`). The agent proposed rebasing onto `main`, which was wrong — the user had to correct it with "why rebase onto main?".

**Root cause:** Missing pre-flight step: before any rebase/sync task on a branch, run `gh pr view --json baseRefName --jq .baseRefName` to resolve the actual PR base. The agent defaulted to `main` without checking the PR.

**Suggested fix:** Add to wk-workflow's Phase 2 pre-rebase preflight: when a task involves rebase/sync, run `gh pr view --json number,baseRefName` first. If a PR exists, `baseRefName` is the authoritative target — never assume default branch. This mirrors the existing "Resolve base" Step 0 in wk-adversarial-review but must fire earlier, during planning.
