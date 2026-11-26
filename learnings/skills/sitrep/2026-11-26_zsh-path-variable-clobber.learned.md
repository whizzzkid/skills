---
skill: wk-sitrep
date: 2026-11-26
type: gap
severity: medium
verified-against-source: no
---

The review-worktree recipe assigns a shell variable named `path`, which breaks command lookup under zsh.

**What happened:** An auto-review worker ran the recipe's worktree step in zsh. Assigning `path=...` made later commands fail to resolve, and the worker had to rerun the step with a different variable name.

**Root cause:** (unverified — inferred from symptom) In zsh, `path` is the array form of `PATH`, so assigning a plain string to it overwrites the search path. The recipe was written as if the shell were bash.

**Suggested fix:** Rename the recipe's variable (for example `wt_dir`) and avoid shell-special names (`path`, `status`, `pipestatus`) in every recipe a subagent may run under zsh.

A second note from the same run: carry-over statuses go stale during the gather itself, because the user merged pull requests while agents ran. Re-read a merge state directly right before any irreversible auto-action (a ticket transition) instead of trusting an agent's earlier snapshot.
