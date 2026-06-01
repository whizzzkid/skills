---
skill: wk-workflow
date: 2026-06-01
type: correction
severity: medium
---

"Branch first on default branch" is a default, not an absolute rule — detect repo convention first.

**What happened:** Agent auto-branched (`feat/workstyle-split`) on a solo-maintained repo that commits directly to main. The branch triggered a pre-commit hook failure, and the user asked why the branch existed at all.

**Root cause:** The rule "if on the default branch, branch first" was applied unconditionally without checking whether the repo actually uses a PR/branch workflow.

**Suggested fix:** Before branching, probe the repo's convention:
1. `git log --oneline --merges -20` — a flat history (no merge commits) signals direct-to-main.
2. Check for CODEOWNERS or branch-protection rules via `gh api repos/{owner}/{repo}/branches/main/protection`.
3. Solo maintainer + flat history + no protection → commit to main directly, skip the branch.
Only branch when the evidence points to a PR-gated workflow.
