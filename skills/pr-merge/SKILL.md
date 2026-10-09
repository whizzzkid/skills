---
name: wk-pr-merge
description: >-
  Use when ready to merge a PR — verifies CI is green, all reviews approved,
  all reviewer comments resolved, no open action items, and an
  adversarial-review clearance covering the body of work,
  then retargets any stacked child PRs onto its base, merges, transitions
  the linked ticket to its terminal state, lists
  any follow-ups or deferred action items, captures a session retro, and
  cleans up the merged worktree.
argument-hint: '[<pr-number-or-url>] [--keep-branch]'
allowed-tools:
  - Bash
  - Read
  - Skill
  - AskUserQuestion
  - "mcp__claude_ai_Github-*__*"
  - "mcp__claude_ai_Jira_*__getJiraIssue"
  - "mcp__claude_ai_Jira_*__transitionJiraIssue"
  - "mcp__claude_ai_Jira_*__addCommentToJiraIssue"
  - "mcp__claude_ai_Jira_*__getTransitionsForJiraIssue"
  - "mcp__claude_ai_Jira_*__searchJiraIssuesUsingJql"
model: sonnet
effort: medium
model-invocable: false
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: "2026.10.09-005632"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
---

# PR Merge

Pre-merge checklist → merge → transition ticket → follow-ups → retro → cleanup.

## When to Use

- "merge this" / "ship it" / "merge the PR" or similar.
- **HARD RULE — a past-tense merge signal is just as binding as an imperative one.**
  "PR landed" / "it's merged" → enter this skill before any other action, never an
  inline Jira MCP transition. Already-MERGED detected
  at Step 1 → skip to Step 7.
- **HARD RULE — enter the skill directly on a merge signal; never hand-do a cosmetic
  pre-step first** (no ticking checkboxes or body edits — Step 5 decides).
- NOT for merging someone else's PR unless user explicitly owns it.

## Step 1: Resolve the PR

```bash
gh pr view --json number,title,baseRefName,headRefName,headRefOid,url,reviewDecision,body,state,mergeCommit
```

Extract: `{number}`, `{title}`, `{base}`, `{head}`, `{head_sha}`, `{url}`,
`{owner}/{repo}` (from URL, never `$GITHUB_ORG`), `{body}`, `{state}`,
`{merge_sha}`, `{entered_merged}` (default false).

- **HARD RULE — explicit PR identity owns every scoped command.** Use
  `{repo_with_owner}` (`{owner}/{repo}`) for reads, retargets, merges, branch
  deletion, verification; `$GITHUB_ORG` only for discovery without an explicit repo.
- Non-zero exit → stop: "No PR found."
- `{state} == "MERGED"` → set `{entered_merged} = true`, skip Steps 2–6, resume Step 7.

### Detect stack membership

Run `gh stack view --json` before Step 2. Stack member → `gh stack checkout {url}`,
reconcile membership parity per
[`references/2026-07-30_remote-stack-membership-parity.md`](references/2026-07-30_remote-stack-membership-parity.md).
Apply Steps 2–5.5 to all members; merge atomically:

```bash
gh stack merge {stack-or-pr-number} --yes --merge-method {allowed-method}
```

Extension lacks `merge` → stop, request upgrade approval.

## Step 2: Verify CI is green

```bash
gh pr checks {number} --repo "{repo_with_owner}" --json name,state,required \
  | jq '.[] | select(.required == true) | {name, state}'
```

- Gate on required checks only; `--json required` error → fall back to check-runs API.
- Verify against `{head_sha}`. `BLOCKED` with green → `wk-gh` ruleset diagnostic.

## Step 3: Verify reviews are approved

- `APPROVED` → proceed. `CHANGES_REQUESTED` → block. `null` → treat as approved.
- `REVIEW_REQUIRED` + bot `COMMENTED` with resolved threads → empty commit to
  trigger re-evaluation. No reviews → block.

## Step 4: Verify all review threads are resolved

**HARD RULE — route unresolved comments to [`wk-pr-resolve`](../pr-resolve/README.md) first.**

Fetch via shared GraphQL query in
[`../pr-review/references/graphql-unresolved-threads.md`](../pr-review/references/graphql-unresolved-threads.md).

- **HARD RULE — never preemptively resolve OR block on the author's own self-review
  threads** — Step 6 merge attempt is the platform probe.
- Triage by severity:
  - **Blocker/Major** → `Skill(wk-pr-resolve, args="{number}")`.
  - **Minor/Info** → never gate merge; offer follow-up tickets in Step 8.
  - **Bot-thrash** (new Minor/Info after ≥1 push round) → offer merge-now with deferred follow-ups.

## Step 5: Verify no open action items

Sync verified test-plan items to `[x]` before scanning. Then:

```bash
echo "{body}" | grep -nE '^\s*- \[ \]'
```

- Non-deferred items: verifiable → attempt, check off passes, report failures
  as blockers. Unverifiable → block and stop.
- "Deferred"/"Follow-up"/"Future work" items → not blockers; collect for Step 8.

## Step 5.5: Verify adversarial-review clearance

Merge consumes clearance, never dispatches review.

- `clear` at HEAD → proceed. Tree-identical rewrite or finding-response commits → carry-forward.
- Unmatched work → stop, return to `wk-workflow` Phase 5.5. No record → stop. `blocked` → stop.
- Explicit session waiver → note and proceed.

## Step 6: Merge

- **HARD RULE — re-resolve remote state at every mutation boundary** — `state`,
  `headRefOid`, `mergeCommit` before each push/merge. Already MERGED → skip to Step 7.
  After an interrupted push/merge, query state + remote head before retrying. See
  [concurrent merge reconciliation](references/concurrent-merge-reconciliation.md).
- **HARD RULE — retarget stacked children BEFORE merging with `--delete-branch`:**
  ```bash
  gh pr list --repo "{repo_with_owner}" --base {head} --state open --json number,headRefName
  ```
  Children found → `gh pr edit {child} --base {base} --repo "{repo_with_owner}"`.
  - **HARD RULE — unconfirmed retarget = HARD STOP.** Re-query; any child still on
    `{head}` → stop, do NOT merge. Transient 500s → retry 2x, then REST.

```bash
gh pr merge {number} {selected-method-flag} --delete-branch --repo "{repo_with_owner}"
```

- Always pass `--repo` (forces API merge; avoids worktree checkout failures).
- **HARD RULE — select from the active ruleset before merging.** Read
  `allowed_merge_methods` via `wk-gh` Step 3; first allowed of squash > rebase > merge.
  Policy error → re-read rulesets.
- Edge cases: [`references/merge-edge-cases.md`](references/merge-edge-cases.md).

## Step 7: Transition the linked ticket

[`references/ticket-transition.md`](references/ticket-transition.md).

## Step 7.5: Post-merge release (when requested)

Ask draft vs. publish; `gh release create`.

## Step 8: Output follow-ups

Collect from: PR body deferred section, review threads resolved as deferrals,
Step 7 tasks requiring manual transition. Route each via `AskUserQuestion`
BEFORE cleanup: **Start now** | **Handoff prompt** | **File ticket**.

## Step 9: Capture session learnings

**HARD RULE — Steps 7-10 are one atomic unit.** A user question mid-flow is not a
stop signal — answer and resume. Compaction does not reset the unit.
Invoke `Skill(wk-retro)` immediately after merge.

## Step 10: Clean up worktree

**HARD RULE — run dead last, after every Step 8 follow-up is resolved.**
`{entered_merged}` → audit for open children before branch deletion.
Removal: [`references/worktree-cleanup.md`](references/worktree-cleanup.md).

## Requirements

`gh` CLI + Jira MCP authenticated. `$GITHUB_ORG` for discovery. `git wtr` alias for cleanup.

---

## Post-Completion

Invoke `wk-learn pr-merge`.
