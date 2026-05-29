---
name: wk-pr-merge
description: >-
  Use when ready to merge a PR — verifies CI is green, all reviews approved,
  all review comments (including self-review) resolved, no open action items,
  then merges, transitions the linked ticket to its terminal state, lists
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
  version: '2026.05.29-071310'
  internal: false
  model:
    claude: claude-sonnet-4-6
---

# PR Merge

Gate the merge of a pull request behind a full pre-merge checklist, then
merge, transition the linked ticket, and summarise follow-ups.

## When to Use

- User wants to merge a branch / PR they believe is ready.
- User says "merge this", "ship it", "merge the PR", or similar.
- **NOT** for merging someone else's PR unless the user explicitly owns the merge.

## Step 1: Resolve the PR

Determine which PR to merge:

```bash
# If an argument was given (number or URL), use it directly.
# Otherwise detect from the current branch:
gh pr view --json number,title,baseRefName,headRefName,headRefOid,url,reviewDecision,body
```

Extract and record:
- `{number}` — PR number
- `{title}` — PR title
- `{base}` — base branch
- `{head_sha}` — current HEAD SHA of the PR branch
- `{url}` — PR URL
- `{body}` — PR description (used in Steps 5 and 8)

If the command exits non-zero (not on a PR branch, no open PR), stop:

> "No open PR found for the current branch. Pass a PR number or URL as an
> argument, or switch to a PR branch."

Announce:
> "Checking PR #`{number}`: _{title}_ → `{base}`"

## Step 2: Verify CI is green

```bash
gh pr checks {number} --json name,state,required \
  | jq '.[] | select(.required == true) | {name, state}'
```

- All required checks must have `state: SUCCESS` (or `NEUTRAL`/`SKIPPED` if the
  repo treats them as passing).
- If **any** required check has `state: FAILURE` or `ERROR`, block:

  > "CI is not green. Failing checks:\n- {name}: {url}\n\nFix the failures and
  > re-run `/wk-pr-merge` when CI is green."

- If **any** required check is `IN_PROGRESS` or `PENDING`, block:

  > "CI is still running ({name}). Re-run once all checks complete."

- Always verify CI against `{head_sha}` — a stale run from a prior commit does
  not count. If `gh pr checks` shows results for a different SHA, block until
  a new run starts.

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

- `reviewDecision == null` (repo has no required reviewers) → treat as approved
  and continue.

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

- **HARD RULE — count ALL unresolved non-outdated threads, regardless of
  author.** Do not filter out self-review threads. Branch protection has no
  concept of "self-review"; every unresolved thread blocks the merge at the
  platform level. Excluding self-authored threads passes the skill's own gate,
  then GitHub rejects the merge with `base branch policy prohibits the merge`.
- For unresolved threads authored by **reviewers or bots**, invoke
  [`wk-pr-resolve`](../pr-resolve/README.md) before proceeding — do not merge,
  do not block-and-stop:

  ```
  Skill(wk-pr-resolve, args="{number}")
  ```

- `wk-pr-resolve` excludes self-review threads from triage, so it leaves
  threads the PR author opened untouched. For any unresolved **self-review**
  threads that remain, resolve them as a pre-merge cleanup — confirm with the
  user, then mark each resolved by `id`:

  ```bash
  gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -F id=<threadId>
  ```

- Re-run the GraphQL query. Continue only when **zero** unresolved non-outdated
  threads remain (any author).

## Step 5: Verify no open action items

Scan the PR body for unchecked task-list items:

```bash
echo "{body}" | grep -nE '^\s*- \[ \]'
```

- Items outside any "deferred" / "follow-up" / "future work" section with
  `- [ ]` are **blockers** — list them and stop:

  > "Unresolved action items in the PR description:\n- {item}\n\n
  > Check them off, move them to a deferred section, or link a tracking
  > ticket before merging."

- Items explicitly labelled "Deferred", "Follow-up PR", "Next sprint", or
  under a heading that contains those phrases are **not blockers** — collect
  them for Step 8's output instead.

- Items with `- [x]` are already done — skip.

## Step 6: Merge the PR

```bash
gh pr merge {number} --squash --delete-branch
```

- Default to squash merge. If the repo's branch-protection settings require
  a merge commit or rebase, use `--merge` or `--rebase` accordingly:

  ```bash
  # Detect repo merge settings if needed:
  gh api repos/{owner}/{repo} --jq '{allow_squash_merge, allow_merge_commit, allow_rebase_merge}'
  ```

- `--delete-branch` deletes the head branch after merge. If the repo has
  "delete branch on merge" disabled and the user has not expressed a
  preference, ask once:

  > "Delete the branch `{head}` after merge? (yes / no)"

- After the command returns, confirm the merge succeeded:

  ```bash
  gh pr view {number} --json state,mergeCommit --jq '{state, mergeCommit: .mergeCommit.oid}'
  ```

  If `state != "MERGED"`, surface the error and stop.

- Record `{merge_sha}` (the merge commit OID) for use in Step 7.

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

1. Fetch the issue and its available transitions:

   ```
   getJiraIssue(key)
   getTransitionsForJiraIssue(key)
   ```

2. Find the terminal transition (first match among: `Done`, `Closed`,
   `Resolved`, `Shipped`, `Complete`).

3. Transition the ticket:

   ```
   transitionJiraIssue(key, transitionId)
   ```

4. Post a shipped comment:

   ```
   addCommentToJiraIssue(key,
     body="Shipped in PR #{number} — {title}.\n{merge_sha}\n\nSee: {url}")
   ```

If no terminal transition is found, note it in the output and skip the
transition — do not block the merge.

### GitHub issues

For each `closes #N` / `fixes #N` reference:

```bash
gh issue close {N} --comment "Shipped in {url} (merge commit {merge_sha})."
```

GitHub auto-close via `Closes #N` only fires when the PR merges into the
repo's default branch. For other base branches, close manually here.

### Asana

No MCP available for Asana. Note each detected URL in the follow-ups output
so the user can transition manually:

> "⚠️ Asana task detected — no MCP available. Transition manually: {url}"

### No ticket found

If no ticket key or issue reference is found anywhere, note it and continue —
do not block.

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

If there are follow-ups, offer once:

> "Want me to file these as GitHub issues or Jira tickets?"

## Step 9: Capture session learnings

- Invoke [`wk-retro`](../retro/README.md) to reflect on the full PR session —
  implementation, review back-and-forth, and merge:

  ```
  Skill(wk-retro)
  ```

- Run after the merge succeeds — the session is complete and its decisions
  are freshest now.
- Failure mode: merging ends the session; ad-hoc context (design choices,
  reviewer trade-offs) is lost if not distilled before the worktree is cleaned.

## Step 10: Clean up the current worktree

- Invoke [`wk-worktree-cleanup`](../worktree-cleanup/README.md) to remove the
  worktree holding the just-merged branch:

  ```
  Skill(wk-worktree-cleanup, args="--current")
  ```

- Run only when the merge happened from inside a dedicated worktree for the PR
  branch. `wk-worktree-cleanup` self-detects the main worktree and skips
  cleanup there — never removes the repo root.
- Step 9's `wk-retro` satisfies `wk-worktree-cleanup`'s pre-delete retro guard;
  it will not re-run retro for the same session.

---

## Common Mistakes

- **Merging with unresolved self-review threads** — self-review threads must
  be resolved (marked resolved in GitHub), not just replied to.
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

---

## Post-Completion

Invoke [`wk-learn`](../learn/README.md) with this skill's short name as the argument
(e.g., `wk-learn pr-merge`).
