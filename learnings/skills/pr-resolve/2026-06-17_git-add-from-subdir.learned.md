---
skill: wk-pr-resolve
date: 2026-06-17
type: gap
severity: medium
---

`git add` on resolved conflict files fails with exit 128 when cwd is a repo subdirectory.

**What happened:** After resolving merge conflicts, `git add <path>` exited 128 ("pathspec did not match any files") because the agent's working directory was a subdirectory of the repo root, making the repo-relative path unresolvable.

**Root cause:** The skill's Step 6 instructs "apply the change" and "commit" but does not specify that staging must be done from the repo root. When a worktree's session cwd is a subdirectory (e.g., a tool or library subfolder), relative paths to top-level files silently mismatch.

**Suggested fix:** In Step 6, before any `git add` for conflict resolution or fix staging, verify cwd against the repo root: `git rev-parse --show-toplevel`. If they differ, use `git -C "$(git rev-parse --show-toplevel)" add <paths>` rather than plain `git add`.
