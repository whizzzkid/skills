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
- **Repo allowlist required.** Filter candidates to repos in the project's
  config `review_repos` allowlist before dispatching any subagent — scope to
  repos the user actively works in, not every repo cloned locally.
  - No allowlist configured → review nothing; report the skipped PRs. Never
    fall back to "all cloned repos".
- **Local clone required.** Base clones at `$GITC_ROOT/$EMPLOYER/<repo>`
  (`$GITC_ROOT` default `$HOME/gitc`). The orchestrator checks
  `test -d "$GITC_ROOT/$EMPLOYER/<repo>"` per PR.
  - Skip and report any repo without a local clone. Never implicitly `git clone`
    — cloning an unfamiliar repo is a side effect the user did not request.
- **Derive concurrency from nested demand, never a fixed count.** Each review
  subagent spawns mandatory nested workers of its own, so a parent occupying the
  last free slot blocks on a child it is required to spawn and the run deadlocks
  until parents are interrupted and the reviews serialized by hand.
  - Budget top-level reviews as
    `floor(runtime_agent_limit / (1 + max_mandatory_nested_fanout))`.
  - Read `max_mandatory_nested_fanout` from the review skill's own contract rather
    than assuming it; unknown → treat as 1, never 0.
  - Budget below 2 → run the reviews serially. Carry the remainder to the next
    `start`; a large queue must never spawn an unbounded fleet.
  - Reserve before launching, never on failure — slot exhaustion mid-fleet cannot
    be recovered without interrupting work already in flight.

## Pending draft only — never submit a live review

- The subagent drives [`/wk-pr-review`](../../pr-review/README.md) Phase 5, which
  posts a **PENDING** (draft) review the user submits from the GitHub UI.
- Never call an endpoint that submits, approves, or requests changes on the
  user's behalf: no `gh pr review --approve/--request-changes/--comment`, no
  `POST /pulls/{n}/reviews` with an `event` field.
- A prose "invoke `/wk-pr-review`" instruction does NOT guarantee the skill's
  exact posting mechanics — an orchestrator can improvise a live submit. Hold
  the subagent to the pending-review contract against its own tool calls, not
  the prose.
- Live reviews are irreversible: per the GitHub API only a still-`PENDING`
  review can be deleted; a submitted approve/request-changes cannot be undone.

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
