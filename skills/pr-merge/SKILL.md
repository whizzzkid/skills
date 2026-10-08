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
  version: "2026.08.26-182049"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
---

# PR Merge

Gate the merge behind a full pre-merge checklist → merge → transition linked
ticket → summarise follow-ups.

## When to Use

- User wants to merge a branch / PR they believe is ready.
- User says "merge this", "ship it", "merge the PR", or similar.
- **HARD RULE — a past-tense merge signal is just as binding as an imperative
  one.** "The PR is merged", "it's been merged", "PR landed", or "update the
  ticket, it merged" triggers this skill **before any other action** — never
  transition the ticket inline via the Jira MCP. The merge event owns the ticket
  transition, follow-up collection, retro, and worktree cleanup; an inline MCP
  call silently skips all but the transition. An already-`MERGED` PR is detected
  by the Step 1 state check, which skips Steps 2–6 and resumes at Step 7.
- **HARD RULE — enter the skill directly on a merge signal; never hand-do a
  cosmetic pre-step first.** Do not tick PR-body checkboxes or edit the body
  before entering — let the Step 5 action-item scan decide whether any checkbox
  actually blocks.
- **NOT** for merging someone else's PR unless the user explicitly owns the merge.

## Step 1: Resolve the PR

```bash
# If an argument was given (number or URL), use it directly.
# Otherwise detect from the current branch:
gh pr view --json number,title,baseRefName,headRefName,headRefOid,url,reviewDecision,body,state,mergeCommit
```

Extract and record:
- `{number}` — PR number
- `{title}` — PR title
- `{base}` — base branch
- `{head}` — head branch (this PR's own branch)
- `{head_sha}` — current HEAD SHA of the PR branch
- `{url}` — PR URL
- `{owner}` / `{repo}` — repository identity parsed from `{url}`; never derive it
  from `$GITHUB_ORG` or the current `origin`
- `{repo_with_owner}` — `{owner}/{repo}`
- `{body}` — PR description (used in Steps 5 and 8)
- `{state}` — PR state; `{merge_sha}` — `mergeCommit.oid` when merged
- `{entered_merged}` — whether the PR was already merged at Step 1; default `false`

- **HARD RULE — explicit PR identity owns every scoped command.** Use
  `{repo_with_owner}` for reads, child retargets, merges, branch deletion, and
  verification. Reserve `$GITHUB_ORG` for discovery without an explicit repo.

- Command exits non-zero (not on a PR branch, no PR) → stop:
  > "No PR found for the current branch. Pass a PR number or URL as an
  > argument, or switch to a PR branch."
- Announce:
  > "Checking PR #`{number}`: _{title}_ → `{base}`"

- **Already merged → skip to Step 7.** Auto-merge / merge-queue commonly lands the
  PR before this skill runs. `{state} == "MERGED"` → set `{entered_merged} = true`, record `{merge_sha}` from
  `mergeCommit.oid`, skip Steps 2–6 (CI, review, thread, and action-item gates are
  moot on a merged PR), and resume at Step 7 (ticket transition, follow-ups, retro,
  worktree cleanup). Never attempt to re-merge.

### Detect stack membership before single-PR gates

- Run `gh stack view --json` after Step 1 and before Step 2.
- Target belongs to a stack → capture its PR-number set, then run
  `gh stack checkout {url}` and re-run `gh stack view --json`. The PR-URL
  checkout is the official remote import path; require exact membership parity
  before gating. A remote-only or local-only member stops the subset path →
  use the imported topology, re-resolve every member from GitHub, then restart
  Steps 1–5.5 across the reconciled set. Import failure or remaining divergence
  is a hard stop. See
  [`references/2026-07-30_remote-stack-membership-parity.md`](references/2026-07-30_remote-stack-membership-parity.md).
- Apply Steps 2–5.5 to every reconciled member.
- Read ruleset `allowed_merge_methods` and verify `gh stack merge --help`
  supports `--yes` plus the selected method.
- Merge the gated set atomically:

  ```bash
  gh stack merge {stack-or-pr-number} --yes --merge-method {allowed-method}
  ```

- Installed extension lacks `merge` or required flags → stop and request
  approval to upgrade the official extension; never silently fall back to
  sequential merges.
- Verify every included PR is `MERGED`, reports the stack merge commit, and the
  target branch points to that commit before Step 7.

## Step 2: Verify CI is green

```bash
gh pr checks {number} --repo "{repo_with_owner}" --json name,state,required \
  | jq '.[] | select(.required == true) | {name, state}'
```

- `--json required` field error → degrade to check-runs API
  (`repos/{owner}/{repo}/commits/{head_sha}/check-runs`), never block.
- Gate on **required checks only**; non-required are informational.
- `SUCCESS` passes; `FAILURE`/`ERROR` → block; `IN_PROGRESS`/`PENDING` → block;
  `CANCELLED` → apply `wk-gh`'s same-head replacement rule.
- Always verify against `{head_sha}` — stale runs don't count.
- `mergeStateStatus: BLOCKED` with green checks → `wk-gh` ruleset diagnostic.

## Step 3: Verify reviews are approved

```bash
gh pr view {number} --repo "{repo_with_owner}" --json reviewDecision,reviews \
  | jq '{reviewDecision, changesRequested: [.reviews[] | select(.state=="CHANGES_REQUESTED") | .author.login]}'
```

- `reviewDecision == "APPROVED"` → proceed.
- `reviewDecision == "CHANGES_REQUESTED"` → block:
  > "Changes requested by: {logins}. Resolve the review before merging."
- `reviewDecision == "REVIEW_REQUIRED"` — check reviews:
  - Bot's latest review `COMMENTED` with all its threads resolved → push empty
    commit (`git commit --allow-empty`) to trigger re-evaluation; re-run Step 3.
  - No reviews or unresolved bot threads → block:
    > "No review submitted. PR requires at least one approval."
- `reviewDecision == null` (repo has no required reviewers) → treat as approved,
  continue.

## Step 4: Verify all review threads are resolved

**HARD RULE — route unresolved comments to [`wk-pr-resolve`](../pr-resolve/README.md) first.**

- Fetch unresolved threads via the shared GraphQL query in
  [`../pr-review/references/graphql-unresolved-threads.md`](../pr-review/references/graphql-unresolved-threads.md).

- **HARD RULE — never preemptively resolve OR block on the author's own
  self-review threads.** They are informational design-rationale notes, not the
  agent's to close. Branch protection *may* count them at the platform level, but
  whether it does is repo-specific — do not assume either way. The Step 6 merge
  attempt is the ground-truth probe: do not resolve self-authored threads as
  pre-merge cleanup, and do not report the PR un-mergeable solely because they
  are open.
- **Triage unresolved reviewer/bot threads by severity before blocking** — an
  unresolved thread is not automatically a merge blocker:
  - **Blocker or Major** (correctness, security, data-loss risk) → invoke
    [`wk-pr-resolve`](../pr-resolve/README.md) before proceeding — do not merge,
    do not block-and-stop:
    ```
    Skill(wk-pr-resolve, args="{number}")
    ```
  - **Minor or Info** (style, abstraction quality, non-critical coverage gap) →
    **never gate the merge.** Do not file (or ask to file) tickets pre-merge —
    merge first, then in the Step 8 output offer to file follow-up Jira/GitHub
    tickets. Ask for the epic/parent only if the user accepts the offer; on a
    filed ticket resolve each thread with a `Tracked in [<KEY>]` reply. The
    ask-and-file flow is a post-merge follow-up gate, not a merge gate.
  - **Bot-thrash → stop the push cycle.** A push produced new-only Minor/Info
    findings for ≥1 round → surface the thrash explicitly and offer
    merge-now-with-deferred-follow-ups. Only a fresh Blocker/Major justifies
    another push; do not chase each new Minor with another round.
- `wk-pr-resolve` excludes self-review threads from triage → leaves
  author-opened threads untouched. Leave them open: proceed to Step 6 without
  resolving them.
- Re-run the GraphQL query. Continue to Step 6 once every **reviewer/bot** thread
  is resolved or triaged; the author's own self-review threads may remain open
  (Step 6 is the platform-level probe).

## Step 5: Verify no open action items

- **Sync verified test-plan items before scanning.** For each `- [ ]` item,
  check whether the current session already verified it (Playwright, CI, manual
  test). Update the PR body to `- [x]` via `gh pr edit --body` before the
  unchecked-item gate runs.

Scan the PR body for unchecked task-list items:

```bash
echo "{body}" | grep -nE '^\s*- \[ \]'
```

- `- [ ]` items outside any "deferred" / "follow-up" / "future work" section
  → triage by verifiability before blocking:
  - **Verifiable** (UI rendering, test output, CLI behavior, dev server state)
    → attempt verification; check off items that pass; report failures as
    blockers with observed evidence.
  - **Unverifiable** (requires production access, external system, manual user
    judgment) → list as **blockers** and stop.
  - All items verified or deferred → proceed; any unverified blocker remains →
    stop:
    > "Unresolved action items in the PR description:\n- {item}\n\n
    > Check them off, move them to a deferred section, or link a tracking
    > ticket before merging."
- Items labelled "Deferred", "Follow-up PR", "Next sprint", or under a heading
  containing those phrases → **not blockers**; collect for Step 8 output.
- `- [x]` items are already done → skip.

## Step 5.5: Verify the adversarial-review clearance

Merge consumes the completion gate's clearance; it never dispatches review.

- Current HEAD has a `clear` record → proceed.
- Latest `clear` predates HEAD → inspect `git log` and `git diff` from its SHA:
  - Tree-identical history rewrite → note carry-forward and proceed.
  - Every commit directly applies an already-surfaced finding, with no new scope,
    refactor, or unrequested logic → match each to its finding, note carry-forward,
    and proceed.
  - Unmatched or new work → stop; return to [`wk-workflow`](../workflow/README.md)
    Phase 5.5 for one delta-scoped re-review.
- No `clear` record → stop; the completion gate never ran. Never invoke review
  from merge.
- `blocked` → stop; fix each blocker via `wk-commit` at the completion gate.
- Explicit current-session waiver → note it and proceed; never infer one.

## Step 6: Merge

- **HARD RULE — re-resolve remote state at every mutation boundary.** Immediately
  before each post-fix push or merge command, fetch `state`, `headRefOid`, and
  `mergeCommit` again. Already `MERGED` → skip the mutation and resume Step 7.
  After an interrupted push or merge, query both PR state and the remote head
  OID before retrying or reporting cancellation; interruption does not prove no
  remote side effect. See [concurrent merge
  reconciliation](references/concurrent-merge-reconciliation.md).
- **HARD RULE — retarget stacked children BEFORE merging with `--delete-branch`.**
  A child PR based on this PR's head branch is closed/orphaned when the merge
  deletes the head: GitHub's automatic base-change on parent merge races with the
  branch deletion and does not complete first. Detect children:
  ```bash
  gh pr list --repo "{repo_with_owner}" --base {head} --state open --json number,headRefName
  ```
  - Empty result → proceed to merge.
  - Any result → retarget EACH child onto this PR's base first, then merge this PR:
    ```bash
    gh pr edit {child} --base {base} --repo "{repo_with_owner}"
    ```
  - **HARD RULE — unconfirmed retarget = HARD STOP.** Re-query after retarget;
    any child still on `{head}` → stop, do NOT merge. Transient 500s → retry
    2x, then use REST `gh pr edit --base`.

```bash
gh pr merge {number} {selected-method-flag} --delete-branch --repo "{repo_with_owner}"
```

- **Always pass `--repo "{repo_with_owner}"`** — forces API-only merge; without
  it, `--delete-branch` runs a local base checkout that fails inside worktrees.
- **HARD RULE — select from the active ruleset before merging.** Read
  `allowed_merge_methods` via `wk-gh` Step 3; choose first allowed in preference
  order `--squash`, `--rebase`, `--merge`. Policy error → re-read rulesets.
- Edge cases (server-side stack flag, squash SHA citations, classifier denial,
  post-merge verification, self-review thread resolution, branch deletion,
  merge verification poll):
  [`references/merge-edge-cases.md`](references/merge-edge-cases.md).
- Record `{merge_sha}` only once `state == "MERGED"`.

## Step 7: Transition the linked ticket

- Follow [`references/ticket-transition.md`](references/ticket-transition.md)
  for footer stripping, boundary-aware detection, transition calls, and failure
  handling.

## Step 7.5: Post-merge release (when requested)

Release request bundled with merge → ask draft vs. publish; warn that
`--draft` defers tag creation. Create via `gh release create`.

## Step 8: Output follow-ups and action items

Collect deferred items from three sources:

1. **PR body deferred section** — unchecked `- [ ]` items under headings
   that contain "deferred", "follow-up", "future work", or "next sprint".
2. **Review threads resolved as deferrals** — any thread where the
   resolution reply contains "track in follow-up", "filed as", or a
   ticket reference.
3. **Asana tasks** from Step 7 that require manual transition.

Output: `## Merge complete` with ticket transitions and follow-up items.

Follow-ups present → route each via `AskUserQuestion` BEFORE Step 10 (cleanup
destroys local context): **Start now** | **Handoff prompt** (self-contained for
new agent) | **File ticket**.

## Step 9: Capture session learnings

- **HARD RULE — Steps 7-10 are one atomic unit.** A user question mid-flow is
  not a stop signal; answer and resume. Context compaction does not reset the
  unit — resume pending steps from the compaction summary.
- Invoke `Skill(wk-retro)` immediately after merge — ad-hoc context is lost
  once the worktree is cleaned.

## Step 10: Clean up the current worktree

- **HARD RULE — run dead last, after every Step 8 follow-up is resolved.**
  Removal destroys local context; a pending reply blocks cleanup.
- `{entered_merged} == true` → audit remote head for open children; retarget
  per Step 6 before deleting the remote branch.
- Local worktree removal:
  [`references/worktree-cleanup.md`](references/worktree-cleanup.md).

---

## Requirements

- `gh` CLI authenticated and in PATH.
- Jira MCP connector authenticated (for Jira ticket transitions).
- `$GITHUB_ORG` set when discovery searches are org-scoped.
- `git wtr` alias defined (worktree cleanup in Step 10) — the bare `Bash` tool
  already permits it; the alias itself must exist in git config.

---
