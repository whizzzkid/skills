---
class: principle
---

# Auto-launch PR reviews — mechanics

Detailed flow for `SKILL.md` § Stage 7 (`start` only). Runs after the live page
is committed. It is an auto-action, not interactive triage — the orchestrator
dispatches read-only-gathering subagents that each drive one review.

## Rule

- **Source, never re-query.** Reuse the Stage 2 GitHub agent's "PRs to review"
  bucket (already `--draft=false --owner="$GITHUB_ORG"`). Re-querying risks
  drift from the compiled report.
- **Local clone required.** Base clones at `$GITC_ROOT/$EMPLOYER/<repo>`
  (`$GITC_ROOT` default `$HOME/gitc`). The orchestrator checks
  `test -d "$GITC_ROOT/$EMPLOYER/<repo>"` per PR.
  - Skip and report any repo without a local clone. Never implicitly `git clone`
    — cloning an unfamiliar repo is a side effect the user did not request.
- **Cap concurrency at 5** review subagents per run; carry the remainder to the
  next `start`. Prevents a large review queue from spawning an unbounded fleet.

## Per-PR subagent

Prepend the gathering-subagent contract (`references/subagent-contract.md`).
Each subagent:

1. `cd "$GITC_ROOT/$EMPLOYER/<repo>"`.
2. Create an isolated worktree for the PR head branch with the user's alias:
   `git wta <pr-head-branch>` (= `git pull; git worktree add worktrees/<branch>
   <branch>`). Fallback when the alias is absent:
   `git worktree add "worktrees/<branch>" "<branch>"`.
3. Invoke [`/wk-pr-review`](../../pr-review/README.md) scoped to that PR.

## Render

- Render each launched review as a `data-done="true"` ⚙️ Auto-Actions item in
  col2, linking the PR — mirrors Stage 2b/2c auto-action rendering.
- Never render an auto-launched review as a passive `data-done="false"` TODO.
