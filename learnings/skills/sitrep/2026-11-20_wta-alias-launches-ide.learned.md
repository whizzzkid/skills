---
skill: wk-sitrep
date: 2026-11-20
type: gap
severity: medium
verified-against-source: yes
---

The auto-review per-PR recipe names a worktree alias that launches an editor, which an unattended subagent must not trigger.

**What happened:** `references/auto-review.md` tells each review subagent to create its worktree with the user's
`wta` git alias. The alias definition (read from git config) ends by running the repo's worktree script or opening
`$IDE` on the new path, so an unattended run would pop an editor window per PR. The orchestrator instead told each
subagent to use plain `git fetch` + `git worktree add --detach` and it worked.

**Root cause:** The recipe treats the alias as equivalent to `git worktree add`, but the alias has an IDE-launch side
effect and a `git pull` on the base clone, neither of which the recipe mentions.

**Suggested fix:** Make the plain `git fetch origin <branch>` + `git worktree add --detach worktrees/<name> FETCH_HEAD`
form the primary recipe and drop the alias; note that the alias opens an editor.
