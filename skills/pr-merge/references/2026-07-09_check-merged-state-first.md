---
class: principle
skill: wk-pr-merge
date: 2026-07-09
---

- **Rule:** Step 1 fetches the PR `state` and, when it is `MERGED`, records the
  merge SHA from `mergeCommit.oid`, skips Steps 2–6 (CI, review, thread, and
  action-item gates), and resumes at Step 7 (ticket transition, follow-ups, retro,
  worktree cleanup). Never attempt to re-merge an already-merged PR.
- **Why:** Auto-merge and merge queues commonly land a PR before this skill runs.
  Without an up-front merged-state check the skill would drive the pre-merge gates
  against a PR that is already closed — wasted work, and a re-merge attempt errors.
  The prior skip rule keyed off the user's phrasing ("already merged"), so it
  missed a silently auto-merged PR the user did not describe as merged.
- **Where:** Step 1 — added `state,mergeCommit` to the `gh pr view --json` fetch
  and a merged-state short-circuit bullet; reconciled the When-to-Use skip rule to
  reference it; README Mermaid gained the `state == MERGED → Step 7` branch.
