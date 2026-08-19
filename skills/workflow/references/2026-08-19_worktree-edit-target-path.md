---
class: principle
---

- **Rule:** In a linked worktree, resolve every edit target path relative to `git rev-parse --show-toplevel` — not a cached absolute path or the repo root.
- **Why:** An absolute path derived from the primary checkout resolves to the main tree's copy, not the worktree's. The edit lands silently in the wrong tree; only `git add` rejecting the path ("outside repository") surfaces the mistake.
- **Where:** Phase 2 (Implement) worktree preflight, alongside the branch-name check.
- **Related:** [`2026-06-03_worktree-preflight.md`](2026-06-03_worktree-preflight.md) (branch-name dimension of the same preflight).
