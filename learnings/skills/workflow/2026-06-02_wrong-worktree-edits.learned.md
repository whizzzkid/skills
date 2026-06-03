---
skill: wk-workflow
date: 2026-06-02
type: gap
severity: medium
---

Verify cwd is the feature worktree before editing files when sibling repo directories exist.

**What happened:** When working from a feature worktree path, the agent ran Edit/Write commands against the main repo's sibling directory instead of the feature worktree. The protect_main hook blocked the commit, requiring a reset and re-apply of all changes in the correct worktree path.

**Root cause:** The skill does not include a step to confirm the cwd matches the intended worktree before beginning implementation. When a project has multiple worktrees sharing the same repo (e.g., `repo/` on `main` and `repo/worktrees/feature/` on the feature branch), the agent can accidentally target the wrong one if file paths are resolved relative to the cwd at Read time vs. Edit time.

**Suggested fix:** Add a Phase 2 preflight: before the first Edit/Write on any code-change task, run `git rev-parse --abbrev-ref HEAD` and confirm the branch matches the intended branch. If the cwd is the wrong worktree (e.g., main branch when a feature branch is expected), stop and re-anchor to the correct path before proceeding.
