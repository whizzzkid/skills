---
class: principle
date: 2026-10-29
severity: medium
---

- **Rule:** Parse `{path}` + `{branch}` pairs from `git worktree list --porcelain` and address every scan, retro, clean,
  and removal by the listed `{path}`; remove with `git worktree remove "{path}" && git branch -D '{branch}'`, never
  `git wtr` or a rebuilt `worktrees/{branch}`.
- **Rule:** Bulk sweeps classify every worktree in one scripted pass, then ask one consolidated question; more than 5
  merged own-authored worktrees needing a retro → ask once: one batched `wk-retro` over the path list, or an explicit
  skip recorded in the report.
- **Why:** Directory names drift from branch names (slashed or renamed branches, manual `git worktree add`), so a path
  rebuilt from the branch name misses the checkout or targets a different one. A per-worktree retro prompt does not
  scale past a handful of worktrees.
- **Where:** Step 1 (path rule), Step 4 (bulk runs), Step 5 (removal command + HARD RULE wording).
- **Also corrected:** `wk-pr-merge` terminal cleanup passed the branch name to `git wtr`; it now removes the worktree
  by its resolved top-level path.
- **Already covered:** detached-HEAD skip (Step 1).
- **Rejected:** "treat a copied local-config file as disposable" — the report names no file, and the disposable
  classifier must stay an explicit list; unverified additions would let unique content be cleaned without prompting.
