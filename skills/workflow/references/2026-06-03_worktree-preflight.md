---
class: principle
---

- **Rule:** Before the first Edit/Write of a code change, confirm the cwd is the intended worktree — `git rev-parse --abbrev-ref HEAD` must equal the feature branch.
- **Why:** When sibling repo dirs or multiple worktrees share one repo, an edit resolved against the wrong worktree gets blocked by the main-branch protect hook, forcing a full reset and re-apply.
- **Where:** Worktree preflight at the top of Phase 2 (Implement).
