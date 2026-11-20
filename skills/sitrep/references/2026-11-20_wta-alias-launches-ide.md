---
class: principle
---

# Unattended worktree recipes use plain git, never a user alias

**Rule** — create each auto-review worktree with `git fetch origin "pull/<n>/head"` plus
`git worktree add --detach worktrees/review-<n> <sha>` (re-detach when the path exists). Never route an unattended
subagent through a user's git alias; read an alias's definition before treating it as the command it wraps.

**Why** — the recipe named the user's worktree alias as equivalent to `git worktree add`, but the alias also ran
`git pull` on the base clone and then opened `$IDE` (or a repo worktree script) on the new path — one editor window
per reviewed PR in an unattended run. A detached, PR-numbered path also avoids colliding with the user's own branch
worktree and works for fork PRs, whose head branch does not exist on `origin`.

**Where** — `SKILL.md` → Stage 7; `references/auto-review.md` → Per-PR subagent step 2; `README.md` → `start`.
