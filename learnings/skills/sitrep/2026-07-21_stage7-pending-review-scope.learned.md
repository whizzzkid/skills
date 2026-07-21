---
skill: wk-sitrep
date: 2026-07-21
type: correction
severity: high
---

Stage 7 auto-launched PR reviews submitted live GitHub reviews instead of
pending drafts, skipped the full `/wk-pr-review` skill chain, and had no
repo scope — an irreversible mistake caught by the user after the fact.

**What happened:** Stage 7's review subagents were told to "invoke
`/wk-pr-review`" in prose, but the orchestrator then posted the findings
itself via a direct approve/request-changes call instead of the skill's
Phase 5 pending-review flow. This submitted 3 live reviews on real PRs
before the mistake was caught. Separately, the PR selection had no repo
allowlist — it picked from every repo cloned under `$GITC_ROOT/$EMPLOYER`
regardless of whether the user was actively working in that repo.

**Root cause:** (1) A prose instruction to "invoke a skill" inside a
subagent prompt does not guarantee the skill's exact posting mechanics are
followed — the orchestrator improvised a `gh pr review --approve` call,
which submits immediately and, per the GitHub API, cannot be deleted or
undone once submitted (only a still-`PENDING` review can be deleted).
(2) No config-driven scope existed for which repos are review-worthy, so
every cloned repo was in play by default.

**Suggested fix:**
- Stage 7 must construct the exact Phase 5 payload itself (or require the
  subagent to return the composed `comments[]` + body for the orchestrator
  to POST) — `POST /pulls/{n}/reviews` with `event` omitted, one entry per
  finding with `path`/`line`/`side`, canonical footer appended, then open
  the returned `html_url`. Never call an endpoint that submits, approves,
  or requests changes on the user's behalf without explicit confirmation.
- Treat "invoke skill X" in a subagent prompt as insufficient on its own
  for anything that performs an irreversible external write; either inline
  the skill's exact mechanical steps in the prompt, or have the subagent
  return structured findings only and let the orchestrator run the
  skill's posting phase directly against its own tool calls.
- Add a required repo allowlist read from the project's local config
  (e.g. a `review_repos` list) and filter Stage 7's PR candidates against
  it before dispatching any review subagent — scope to repos the user is
  actively working in, not everything cloned locally.
