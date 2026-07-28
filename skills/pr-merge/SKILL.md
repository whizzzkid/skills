---
name: wk-pr-merge
description: >-
  Use when ready to merge a PR — verifies CI is green, all reviews approved,
  all reviewer comments resolved, no open action items, a clear
  adversarial-review verdict against current HEAD,
  then retargets any stacked child PRs onto its base, merges, transitions
  the linked ticket to its terminal state, lists
  any follow-ups or deferred action items, captures a session retro, and
  cleans up the merged worktree.
argument-hint: '[<pr-number-or-url>]'
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
  version: "2026.07.28-171054"
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
- `{body}` — PR description (used in Steps 5 and 8)
- `{state}` — PR state; `{merge_sha}` — `mergeCommit.oid` when merged

- Command exits non-zero (not on a PR branch, no PR) → stop:
  > "No PR found for the current branch. Pass a PR number or URL as an
  > argument, or switch to a PR branch."
- Announce:
  > "Checking PR #`{number}`: _{title}_ → `{base}`"

- **Already merged → skip to Step 7.** Auto-merge / merge-queue commonly lands the
  PR before this skill runs. `{state} == "MERGED"` → record `{merge_sha}` from
  `mergeCommit.oid`, skip Steps 2–6 (CI, review, thread, and action-item gates are
  moot on a merged PR), and resume at Step 7 (ticket transition, follow-ups, retro,
  worktree cleanup). Never attempt to re-merge.

## Step 2: Verify CI is green

```bash
gh pr checks {number} --json name,state,required \
  | jq '.[] | select(.required == true) | {name, state}'
```

- **HARD RULE — a `--json` field error must degrade, never block; the `required`
  field is version-dependent.** `gh pr checks --json …,required` errors
  `Unknown JSON field: "required"` on `gh` builds that omit it. On that error,
  fall back to per-check conclusions from the check-runs API against
  `{head_sha}`, and cross-verify with the CI provider's own CLI when available:
  ```bash
  gh api repos/{owner}/{repo}/commits/{head_sha}/check-runs \
    --jq '.check_runs[] | {name, status, conclusion}'
  ```
  Treat `conclusion` `success`/`neutral`/`skipped` as passing. Never let a
  `--json` field error stall the gate — degrade to an alternate source.
- **Important — poll and gate on `required == true` only.** The `jq` filter above
  drops non-required checks for a reason: informational checks (security scanners,
  dependency bots) often queue indefinitely. Never wait on, poll, or block the
  merge for a non-required check — report it as informational, not a blocker.
- All required checks must be `state: SUCCESS` (or `NEUTRAL`/`SKIPPED` if the
  repo treats them as passing).
- Any required check `state: FAILURE` or `ERROR` → block:
  > "CI is not green. Failing checks:\n- {name}: {url}\n\nFix the failures and
  > re-run `/wk-pr-merge` when CI is green."
- Any required check `IN_PROGRESS` or `PENDING` → block:
  > "CI is still running ({name}). Re-run once all checks complete."
- Always verify CI against `{head_sha}` — a stale run from a prior commit does
  not count. `gh pr checks` showing a different SHA → block until a new run starts.

## Step 3: Verify reviews are approved

```bash
gh pr view {number} --json reviewDecision,reviews \
  | jq '{reviewDecision, changesRequested: [.reviews[] | select(.state=="CHANGES_REQUESTED") | .author.login]}'
```

- `reviewDecision == "APPROVED"` → proceed.
- `reviewDecision == "CHANGES_REQUESTED"` → block:
  > "Changes requested by: {logins}. Resolve the review before merging."
- `reviewDecision == "REVIEW_REQUIRED"` (no reviews yet) → block:
  > "No review has been submitted. The PR requires at least one approval."
- `reviewDecision == null` (repo has no required reviewers) → treat as approved,
  continue.

## Step 4: Verify all review threads are resolved

**HARD RULE — route unresolved comments to [`wk-pr-resolve`](../pr-resolve/README.md) first.**

- Fetch unresolved threads via GraphQL before any merge action:

  ```bash
  gh api graphql -f query='
    query($owner:String!, $repo:String!, $number:Int!) {
      repository(owner:$owner, name:$repo) {
        pullRequest(number:$number) {
          reviewThreads(first:100) {
            nodes { id isResolved isOutdated path line
              comments(first:1) { nodes { author { login } body } }
            }
          }
        }
      }
    }' -F owner="{owner}" -F repo="{repo}" -F number={number} \
    --jq '.data.repository.pullRequest.reviewThreads.nodes
          | map(select(.isResolved == false and .isOutdated == false))'
  ```

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

Scan the PR body for unchecked task-list items:

```bash
echo "{body}" | grep -nE '^\s*- \[ \]'
```

- `- [ ]` items outside any "deferred" / "follow-up" / "future work" section
  → **blockers**; list and stop:
  > "Unresolved action items in the PR description:\n- {item}\n\n
  > Check them off, move them to a deferred section, or link a tracking
  > ticket before merging."
- Items labelled "Deferred", "Follow-up PR", "Next sprint", or under a heading
  containing those phrases → **not blockers**; collect for Step 8 output.
- `- [x]` items are already done → skip.

## Step 5.5: Verify the adversarial-review verdict

The merge is where the review gate is enforced — publishing is ungated, so this
is the only step that blocks on it. Never merge, and never enable
`gh pr merge --auto`, without a `clear` verdict covering current HEAD.

- Read the clearance record first; a `clear` verdict covering current HEAD → merge,
  never re-run it. This step adds no second review.
- No record at all → the completion gate never ran: invoke
  [`wk-adversarial-review`](../adversarial-review/README.md) once here and block on
  it. Record present but predating HEAD → ONE delta-scoped re-review; a clearance
  against an earlier SHA does not carry forward.
- `blocked` → fix each blocker via `wk-commit`, re-invoke until clear. Do not
  merge past an open blocker.
- Waived by an explicit current-session user instruction → note the waiver and
  proceed; never infer a waiver from silence or from a denied permission prompt.

- **HARD RULE — retarget stacked children BEFORE merging with `--delete-branch`.**
  A child PR based on this PR's head branch is closed/orphaned when the merge
  deletes the head: GitHub's automatic base-change on parent merge races with the
  branch deletion and does not complete first. Detect children:
  ```bash
  gh pr list --repo "$GITHUB_ORG/{repo}" --base {head} --state open --json number,headRefName
  ```
  - Empty result → proceed to merge.
  - Any result → retarget EACH child onto this PR's base first, then merge this PR:
    ```bash
    gh pr edit {child} --base {base} --repo "$GITHUB_ORG/{repo}"
    ```
  - **HARD RULE — an unconfirmed child retarget is a HARD STOP; never merge past it.**
    Re-query children after retargeting and verify EVERY child's
    `baseRefName == {base}`. Any child still based on `{head}` — after the
    transient-error retries below are exhausted — means the retarget did not land →
    **stop, do NOT run the merge command.** Merging with `--delete-branch` deletes
    `{head}` and closes/orphans that child; a failed retarget followed by a merge is
    exactly how children get silently closed. Report the un-retargeted child numbers
    and the failure to the user; let them retarget manually or fix permissions, then
    re-run. Never continue on a partial or failed retarget.
  - **Transient 500-class errors here are benign — do not pause the merge.** The
    `gh pr edit --base` (REST) path above is the robust one; if any GraphQL
    mutation in this flow returns a 500-class error ("Something went wrong while
    executing your query"), it is a retryable transient — retry up to 2×, then
    use the REST equivalent. Never treat it as a hard failure.

```bash
gh pr merge {number} --squash --delete-branch --repo "$GITHUB_ORG/{repo}"
```

- **Always pass `--repo "$GITHUB_ORG/{repo}"`** — forces GitHub API-only
  behavior, skips local branch manipulation. Without it,
  `gh pr merge --delete-branch` runs a local checkout of the base branch and
  fails inside a git worktree where the base is already checked out elsewhere
  (`fatal: '<base>' is already used by worktree at ...`). The `--repo` form is
  idempotent in both worktree and regular checkouts.
- **HARD RULE — always attempt squash first.** Run the `--squash` command above
  on every merge. Fall back only on **failure** — non-zero exit (squash
  disallowed by branch protection, or a merge error).
- Squash failure → detect allowed methods, retry next best in order
  **`--rebase` then `--merge`** (first allowed wins — rebase keeps linear
  history; merge commit is the universal fallback). **Read the ruleset, not the
  repo-level fields** — `repos/{owner}/{repo}`'s `allow_*_merge` describe repo
  *settings* and report every method allowed even where a ruleset forbids it
  (`wk-gh` Step 3):
  ```bash
  gh api repos/{owner}/{repo}/rulesets/{id} \
    --jq '.rules[] | select(.type=="pull_request").parameters.allowed_merge_methods'
  ```
- Never switch away from squash when the squash command succeeds.
- **Squash collapses the branch into one new commit, so every per-branch SHA
  recorded elsewhere becomes unreachable from the base.** Before squashing a branch
  whose individual commits are cited outside git (plan doc, PR body, tracking
  issue), tell the user the citations will break and agree the remap first — a
  squash-only repo makes this a hard constraint, not a preference.
- **HARD RULE — host permission-classifier denial is a failure mode distinct from
  branch protection.** A "Blocked by classifier" / permission-layer denial of `gh
  pr merge` is NOT a non-zero merge error → do **not** retry verbatim and do
  **not** fall back to another merge method (the host layer blocks irreversible
  actions independent of the skill's own tool allowlist; a different method is
  denied identically). Explain the two-layer model (skill allowlist vs. host
  classifier) and that an explicit `Bash(gh pr merge:*)` **settings.json** rule —
  or a manual user merge — is required to proceed.
  - A manual or past-tense merge by the user after denial IS the already-`MERGED`
    path — re-run Step 1; on `state == "MERGED"`, resume Step 7. Never re-attempt.
- **Post-merge read-only verification needs standing allow rules.** Step 6's
  `gh pr view` / `gh pr checks` state polls are blocked by the auto-mode
  classifier unless `Bash(gh pr view:*)` and `Bash(gh pr checks:*)` are in the
  allowed tools — recommend adding both as a prerequisite. Run each read-only call
  as a standalone invocation: an allow rule matches only when the allowed command
  is the whole invocation, so a pipe to `grep`/`jq` or a compound (`&&`, e.g.
  `rm … && gh pr view`) re-triggers the classifier. Do any grep/jq filtering in a
  separate step (`--jq` is a `gh` flag, not a pipe → still matches).
- **Squash rejected with `base branch policy prohibits the merge` and the only
  unresolved threads left are the author's own self-review** → this is the sole
  case that resolves them (not a method fallback — merge-commit won't help). Ask
  the user first; on yes, mark each resolved by `id`, then retry the squash:
  ```bash
  gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -F id=<threadId>
  ```
  Never auto-resolve self-authored threads without the user's explicit yes.
- `--delete-branch` deletes the head branch after merge. Repo has "delete branch
  on merge" disabled and user has not expressed a preference → ask once:
  > "Delete the branch `{head}` after merge? (yes / no)"
- **HARD RULE — never declare "Merge complete" until `state == "MERGED"`.**
  `gh pr merge --auto` and merge-queue repos return success while the PR is
  only *queued*; an immediate state check returns `OPEN`. Poll until merged or
  ~60s timeout:
  ```bash
  for i in $(seq 1 12); do
    state=$(gh pr view {number} --json state --jq .state)
    [ "$state" = "MERGED" ] && break
    sleep 5
  done
  gh pr view {number} --json state,mergeCommit --jq '{state, mergeCommit: .mergeCommit.oid}'
  ```
- Timeout (`state != "MERGED"`) → re-fetch blockers, stop, do **not** proceed to
  Step 7 — never log a null SHA as success:
  ```bash
  gh pr view {number} --json mergeStateStatus,reviewDecision
  # plus the Step 4 unresolved-threads query
  ```
  > "Auto-merge queued but PR has not merged after ~60s. Likely blockers:
  > {unresolved threads / failed checks / changes requested}."
- Record `{merge_sha}` (the merge commit OID) only once `state == "MERGED"`.

## Step 7: Transition the linked ticket

Detect ticket references from the PR title, body, and branch name:

```bash
# Jira: any [A-Z][A-Z0-9]+-\d+ token
echo "{title} {branch} {body}" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+'

# GitHub issues: closes/fixes/resolves #N annotations
echo "{body}" | grep -ioE '(closes?|fixes?|resolves?)\s+#[0-9]+'

# Asana: app.asana.com URLs
echo "{body}" | grep -oE 'https://app\.asana\.com/[^[:space:]]+'
```

### Jira tickets

For each detected Jira key:

1. Fetch issue + available transitions:
   ```
   getJiraIssue(key)
   getTransitionsForJiraIssue(key)
   ```
2. Find the terminal transition (first match among: `Done`, `Closed`,
   `Resolved`, `Shipped`, `Complete`).
3. Transition:
   ```
   transitionJiraIssue(key, transitionId)
   ```
4. Post a shipped comment:
   ```
   addCommentToJiraIssue(key,
     body="Shipped in PR #{number} — {title}.\n{merge_sha}\n\nSee: {url}")
   ```

No terminal transition found → note in output, skip the transition, do not
block the merge.

**Jira MCP unavailable / unauthenticated** (connector tools error or absent) →
do not block the merge. Surface the detected key and its terminal state in the
Step 8 follow-ups for manual transition, mirroring the Asana fallback:

> "⚠️ Jira MCP unavailable — transition `<KEY>` to Done manually: {url}"

### GitHub issues

For each `closes #N` / `fixes #N` reference:

```bash
gh issue close {N} --comment "Shipped in {url} (merge commit {merge_sha})."
```

GitHub auto-close via `Closes #N` only fires when the PR merges into the repo's
default branch. For other base branches, close manually here.

### Asana

No MCP available for Asana. Note each detected URL in the follow-ups output so
the user can transition manually:

> "⚠️ Asana task detected — no MCP available. Transition manually: {url}"

### No ticket found

No ticket key or issue reference found anywhere → note it, continue, do not
block.

## Step 8: Output follow-ups and action items

Collect deferred items from three sources:

1. **PR body deferred section** — unchecked `- [ ]` items under headings
   that contain "deferred", "follow-up", "future work", or "next sprint".
2. **Review threads resolved as deferrals** — any thread where the
   resolution reply contains "track in follow-up", "filed as", or a
   ticket reference.
3. **Asana tasks** from Step 7 that require manual transition.

Format the output:

```
## Merge complete ✓

PR #{number} merged as {merge_sha} into `{base}`.

### Ticket transitions
- ✅ {JIRA-KEY} → Done
- ✅ GitHub issue #{N} → closed
- ⚠️ Asana {url} — transition manually

### Follow-ups and action items
- {item} — {why deferred} → suggested tracking: {jira/github issue}
- ...

(No follow-ups.) ← emit only when the list is empty
```

Follow-ups present → offer once:

> "Want me to file these as GitHub issues or Jira tickets?"

## Step 9: Capture session learnings

- **HARD RULE — Steps 7-10 are one unit; a user question mid-flow is not a stop
  signal.** After answering any digression during Steps 7-10, note the pending
  step and resume it immediately. Treating a question as session termination
  leaves the ticket un-transitioned, the retro uncaptured, or the worktree
  uncleaned. Never wait for an explicit "did you finish?" re-prompt.
- **HARD RULE — context compaction does not reset the Steps 7-10 unit.** A
  mid-turn compaction is indistinguishable from a clean start to a resuming
  session. When resuming from a compaction summary that shows `wk-pr-merge` was
  active with any of Steps 7-10 listed pending, execute those steps before any
  other work — the compaction summary is the authoritative source for which
  steps remain.
- Invoke [`wk-retro`](../retro/README.md) to reflect on the full PR session —
  implementation, review back-and-forth, and merge:
  ```
  Skill(wk-retro)
  ```
- Run after the merge succeeds — session is complete and its decisions are
  freshest now.
- Failure mode: merging ends the session; ad-hoc context (design choices,
  reviewer trade-offs) is lost if not distilled before the worktree is cleaned.

## Step 10: Clean up the current worktree

- **HARD RULE — worktree cleanup is the point of no return; run it dead last,
  only after every pending question is answered.** Removing the worktree destroys
  the branch / PR / local context that filing follow-ups (the Step 8 offer),
  answering a user digression, or acting on any accepted item depends on — a
  question raised after cleanup cannot be resolved. Before removing: confirm zero
  questions are outstanding — the Step 8 follow-up-filing offer is answered and any
  accepted filing is done. A pending reply blocks cleanup; wait for it, act on the
  answer, then clean up. Never clean up early to "finish faster".
- Remove the just-merged worktree with the `git wtr <name>` alias — a one-shot
  `git worktree remove worktrees/<name>` + `git branch -D <name>`. `<name>` is
  the PR head branch, which is also the worktree dir name under `worktrees/`:
  ```bash
  # git worktree remove refuses the CURRENT worktree → chdir to main first.
  main=$(git worktree list --porcelain | awk 'NR==1{print $2}')
  cd "$main" && git wtr "{head}"
  ```
- **`git wtr` fails on dirty files → triage before escalating.** Run `git status
  --short`; if every entry is a recognizable throwaway artifact (test-runner state
  like rspec last-failures, `tmp/`, coverage output), delete just those files and
  retry `git wtr` once. Reserve `--force` (and any confirmation ask) for genuine
  uncommitted work the user might want — never default to `--force`.
- **Run only from inside a dedicated `worktrees/<name>` checkout.** Skip the
  step entirely when the merge ran from the repo root — never remove it.
- The merge is already confirmed (`state == "MERGED"`), so the branch-merged
  safety check is moot; `git wtr` force-deletes the local branch and Step 6's
  `--delete-branch` already removed the remote one.

---

## Common Mistakes

- **Auto-resolving the author's own self-review threads** — never resolve them
  as routine pre-merge cleanup; leave them open and let the Step 6 merge attempt
  probe whether branch protection actually counts them.
- **Skipping the CI re-check after a push** — CI runs are tied to a SHA;
  always verify the run is against the current `{head_sha}`.
- **Assuming `Closes #N` auto-transitions Jira** — `Closes` only closes
  GitHub Issues; Jira always requires an explicit API transition.
- **Blocking on Asana** — no MCP exists for Asana; surface the URL and move
  on rather than stopping the merge.

## Quick Reference

| Invocation | Behavior |
|------------|----------|
| `/wk-pr-merge` | Merge PR for current branch |
| `/wk-pr-merge 123` | Merge PR #NNN explicitly |

## Requirements

- `gh` CLI authenticated and in PATH.
- Jira MCP connector authenticated (for Jira ticket transitions).
- `$GITHUB_ORG` set if repos are org-scoped.
- `git wtr` alias defined (worktree cleanup in Step 10) — the bare `Bash` tool
  already permits it; the alias itself must exist in git config.

---

## Post-Completion

Invoke [`wk-learn`](../learn/README.md) with this skill's short name as the argument
(e.g., `wk-learn pr-merge`).
