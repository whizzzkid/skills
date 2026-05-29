---
name: wk-pr-merge
description: >-
  Use when ready to merge a PR — verifies CI is green, all reviews approved,
  all review comments (including self-review) resolved, no open action items,
  then merges, transitions the linked ticket to its terminal state, and lists
  any follow-ups or deferred action items.
argument-hint: '[<pr-number-or-url>]'
allowed-tools:
  - Bash
  - Read
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
  version: '2026.05.29-021645'
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

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Accept an optional PR number or URL as argument.
  - If no argument, detect the PR for the current branch via `gh pr view`.
  - Extract: PR number, title, base branch, head SHA, CI status,
    review state, open threads, linked ticket keys/URLs.
-->

## Step 2: Verify CI is green

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - All required checks must be passing (no failing or pending required
    checks). Use `gh pr checks` to get the status.
  - If any required check is failing, block and report which checks failed
    and link to the logs.
  - If any required check is still running, block and offer to re-check.
-->

## Step 3: Verify reviews are approved

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - At least one approved review required (or the repo has no required
    reviewers — detect via `gh pr view --json reviewDecision`).
  - If any reviewer has requested changes, block and list who.
  - If no review exists yet, block and report.
-->

## Step 4: Verify all review threads are resolved

**HARD RULE — route unresolved comments to [`wk-pr-resolve`](../pr-resolve/README.md) first.**

- Detect unresolved review threads before any merge action (CI re-check,
  approval check, the merge itself).
- If **any** unresolved thread exists, invoke
  [`wk-pr-resolve`](../pr-resolve/README.md) before proceeding — do not
  merge, do not block-and-stop.

  ```
  Skill(wk-pr-resolve, args="<pr-number-or-url>")
  ```

- Re-run the unresolved-thread check after `wk-pr-resolve` returns.
  Continue the merge only when zero unresolved threads remain.
- Exclude self-review threads from the unresolved count per
  `wk-pr-resolve`'s own exclusion rules — they are not reviewer feedback.
- Failure mode: merging or halting on unresolved feedback strands the
  reviewer's comments unaddressed in a merged PR.

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Fetch all review threads via the GitHub GraphQL reviewThreads API.
  - Count unresolved threads (isResolved: false, isOutdated: false).
  - Self-review comments (pending reviews submitted by the PR author)
    must also be resolved.
  - If any unresolved thread exists, list each one (file, line, comment
    excerpt) and block.
  - "Resolved" means the thread is marked resolved in GitHub — not just
    that a reply was posted.
-->

## Step 5: Verify no open action items

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Scan the PR body for unchecked task list items: `- [ ]`.
  - Scan the PR body's "Follow-ups" / "Action items" / "TODO" sections.
  - If any unchecked item exists that is NOT in a "deferred" section,
    block and list them.
  - Items explicitly labelled "deferred", "follow-up PR", "next sprint",
    or in a designated future-work section are OK to proceed.
-->

## Step 6: Merge the PR

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Default to squash merge unless the repo's settings or branch
    protection require otherwise.
  - Use `gh pr merge <number> --squash --auto` (or `--merge` /
    `--rebase` based on repo default detected from settings).
  - After merge, confirm HEAD on the base branch advanced.
  - Delete the head branch if the repo has "delete branch on merge"
    enabled, or ask the user if not.
-->

## Step 7: Transition the linked ticket

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Detect ticket keys from the PR body / title / branch name:
      Jira: [A-Z][A-Z0-9]+-\d+ pattern or atlassian.net/browse/ URL
      GitHub issue: #\d+ closes/fixes/resolves annotation
      Asana: app.asana.com URL (no MCP available — note limitation)
  - For Jira tickets:
      Fetch current status; determine the "done" transition (look for
      transitions whose name matches Done/Closed/Resolved/Shipped).
      Transition to Done.
      Post a comment: "Shipped in PR #<N> — <PR title>. <optional
      1-sentence summary of what changed>."
  - For GitHub issues: `gh issue close <N>` with a comment referencing
    the merge commit.
  - If no ticket is found, note that and continue (don't block).
-->

## Step 8: Output follow-ups and action items

<!-- RED phase not yet run — fill in after testing baseline behavior -->

<!-- DESIGN NOTES:
  - Collect from: (a) PR body deferred items, (b) review thread replies
    that were resolved with a "track in follow-up" note, (c) inline
    TODO comments added in the diff (optional, based on user preference).
  - Format as a bulleted list: what, why it was deferred, suggested
    tracking location (new Jira ticket / GitHub issue).
  - If no follow-ups exist, say so explicitly.
-->

## Common Mistakes

- **Merging with unresolved self-review threads** — self-review comments
  are posted as GitHub review threads and must be explicitly resolved,
  not just acknowledged by a reply.
- **Skipping the CI re-check after a force-push** — the last CI run may
  be against a stale SHA; always check CI against the HEAD SHA being merged.
- **Assuming `Closes #N` transitions the ticket** — GitHub auto-close only
  applies to GitHub Issues, not Jira. Jira always requires an explicit
  transition.

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
