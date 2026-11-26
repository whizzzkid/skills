---
class: principle
---

# Review-worktree recipe clobbered zsh's search path; stale merge state before a transition

**Rule** — recipe variables never reuse a zsh special name (`wt_dir`, never `path`). Re-read a linked PR's merge state
directly, right before any irreversible auto-action (a ticket transition), never from a gathering agent's snapshot.

**Why** — the auto-review worktree step assigned `path=…`; under a zsh subagent shell that replaced `PATH` and later
commands failed to resolve (reproduced, zsh 5.9, rc 127). Separately, PRs merged while gathering agents ran, so their
carry-over statuses were stale by compile time.

**Where** — `references/auto-review.md` → Per-PR subagent step 2 (variable renamed, note added pointing at
`wk-workstyle-shell`, which owns and escalates the naming rule); `SKILL.md` → Stage 2b (re-read at transition time).
