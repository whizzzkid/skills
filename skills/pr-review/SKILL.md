---
name: wk:pr-review
description: >-
  Thorough, critical code review of a GitHub pull request. Use when asked to
  review a PR, review code changes, help review this PR, create review comments,
  or investigate a pull request. Reads existing review comments, resolves stale
  threads, builds a playground to validate assumptions, runs experiments, and
  creates pending review comments via GitHub API.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr checkout:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git pull:*)"
  - "Bash(grep:*)"
  - "Bash(.review-playground/:*)"
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - Agent
  - AskUserQuestion
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.2.0'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Review

Automated, thorough code review that investigates changes deeply, builds a
playground to validate assumptions, and posts encouraging but critical review
comments as a pending GitHub review.

## Phase 1: Context

Determine the PR under review and gather all relevant context.

**If already on a PR branch:**

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews
```

**If on main/master or no PR is detected:** Ask the user for a PR number or URL,
then check out the branch:

```bash
gh pr checkout <number>
```

### Verify local HEAD matches PR HEAD

Before reading any files, confirm the local worktree is at the PR's HEAD:

```bash
LOCAL_HEAD=$(git rev-parse HEAD)
PR_HEAD=$(gh pr view --json headRefOid --jq '.headRefOid')
if [ "$LOCAL_HEAD" != "$PR_HEAD" ]; then
  echo "⚠ Local HEAD ($LOCAL_HEAD) ≠ PR HEAD ($PR_HEAD). Pulling..."
  git pull --ff-only || echo "Fast-forward failed — will use gh pr diff as source of truth"
fi
```

If the pull fails, use `gh pr diff` as the authoritative source for what
changed and `gh api repos/{owner}/{repo}/contents/{path}?ref={pr_head_sha}`
to read file contents at the PR HEAD instead of local `Read`. Note the desync
in the review summary so the user is aware.

### Collect context

Collect and internalize:
- PR title, description, and linked issues
- Full diff: `gh pr diff`
- List of changed files and their scope
- Commit history on this branch
- The base branch to understand what's being merged into

Before moving on, announce what you found:
> "Reviewing PR #N: *title* — X files changed, Y commits. Base: `main`. Let me dig in."

## Phase 2: Existing Review Comments

Fetch all existing review comments on the PR, identify stale threads, and
optionally resolve them before beginning investigation.

### Fetch comments

Retrieve all inline review comments from every reviewer:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

Skip comments where `in_reply_to_id` is set — those are reply chains, not
top-level threads. Focus on root comments that anchor each conversation.

### Identify stale comments

A comment is **stale** when any of these are true:

- `position` is `null` — GitHub marks the diff position as outdated
- The file at `path` was modified in commits after the comment's `updated_at`
- The referenced line content no longer matches the current code

Read the current file and compare the line to confirm. Categorize each comment:

- **Stale (fixed):** The underlying issue is clearly resolved in the current code.
- **Stale (unclear):** The position is outdated but it is not obvious whether the
  issue was addressed. Leave these for the author or reviewer to handle.
- **Active:** Still applies to the current code.

### Present and ask before resolving

**HARD RULE: Never resolve review threads without explicit user consent.**
Present the categorized list and wait for confirmation.

```
Stale comments (resolved in code):
1. [stale] src/auth.ts:42 by @reviewer — "Session token not invalidated" → Fixed in abc123
2. [stale] src/utils.ts:18 by @reviewer — "Rename processData" → Renamed to transformPayload

Stale comments (unclear):
3. [stale?] src/api.ts:33 by @reviewer — "Is this timeout intentional?"

Active comments:
4. [active] src/cache.ts:91 by @reviewer — "LRU size should be configurable"

Would you like me to resolve threads 1 and 2?
(Thread 3 will be left for manual review.)
```

### Resolve confirmed threads

After the user confirms, query for thread node IDs via GraphQL:

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes { body path line }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F number={number}
```

Match each confirmed stale comment to its thread by `path` + `line` + `body`,
then resolve:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="THREAD_NODE_ID"
```

### Summarize

Announce what was found before moving on:

> "Found X existing review comments (Y active, Z resolved as stale). Carrying
> N active comments forward into investigation."

The list of active unresolved comments becomes context for the next phase.

## Phase 3: Investigation

Read every changed file in full — not just the diff hunks. Understand the
surrounding code, call sites, downstream consumers, and existing test coverage.

**Carry forward existing comments.** Be aware of active unresolved review
comments from Phase 2. Do not duplicate comments that already exist. If you
find an issue that relates to an existing comment thread, reference it rather
than creating a separate observation. Focus on finding **new** issues that no
existing reviewer has raised.

**Be adversarial.** Your job is to find what the author missed:
- Bugs and logic errors
- Missed edge cases and failure modes
- Security vulnerabilities
- Performance regressions
- Broken contracts or API changes
- Race conditions and concurrency issues
- Missing or inadequate error handling
- Inconsistencies with existing patterns

There is no fixed checklist. You decide what matters based on the actual changes.
Follow the code wherever it leads — if a changed function is called from 5
places, read all 5. If a new dependency is added, evaluate it.

Take notes as you go. You'll use these findings to build the playground and
formulate comments.

## File Access Rules

**HARD RULE: Write and Edit tools may ONLY target files under
`.review-playground/` in the project root. Never write or edit files
outside of `.review-playground/`. Never commit playground files.**

Read, Glob, and Grep may access any path (read-only) for code investigation.

## Phase 4: Playground

Create a `.review-playground/` directory at the repository root. This is your
workspace for experiments — **never commit these files**.

Ensure `.review-playground/` is in `.gitignore`:

```bash
if ! grep -qxF '.review-playground/' .gitignore 2>/dev/null; then
  echo '.review-playground/' >> .gitignore
fi
```

Build whatever combination the changes call for:

### Scratch scripts

Executable scripts that exercise changed code paths. Run them and observe
behavior. Example: a script that calls the modified function with various inputs
to see how it behaves at boundaries.

### Test cases

Runnable tests (in the project's test framework) that verify the PR's behavior.
Focus on:
- Happy path — does the change work as described?
- Sad path — how does it handle failure, invalid input, missing data?
- Edge cases — boundaries, empty collections, null values, large inputs, concurrency

### HTML visualizations

When changes benefit from visual explanation — UI changes, data flow
modifications, state transitions, or a critical-change heatmap — create an
HTML file in the playground that visualizes what's happening.

### Report findings

After running experiments, summarize what you discovered:
- Confirmed behaviors
- Broken assumptions
- Surprising or unexpected results
- Things that work but seem fragile

> "Playground built at `.review-playground/`. Here's what I found: ..."

## Phase 5: Review Comments

Formulate inline review comments anchored to specific lines in the diff.

### Tone

Be encouraging and constructive. The goal is to help the author improve the
code, not to block the PR. Acknowledge good work. Frame suggestions as
opportunities, not demands.

### Severity

Tag each comment with a severity prefix:

- **`blocker:`** Must be fixed before merge. Reserve for critical bugs, security
  issues, data loss risks, or broken functionality. Use sparingly.
- **`suggestion:`** Good for a follow-up change. Style nits, naming improvements,
  refactoring ideas, pedantic observations, potential optimizations.
- **`question:`** Genuine uncertainty about intent or behavior. Ask the author
  to clarify.
- **`praise:`** Call out good patterns, clever solutions, or well-handled edge
  cases. Reinforce good work.

**Default to `suggestion` unless something is genuinely critical.** Frame
non-blocking items as "good candidate for a follow-up" or "something to
consider in a future pass."

### Comment format

Each comment body should follow this structure:

```
**{severity}:** {The observation or concern}

{Optional: context, evidence from playground experiments, or suggested fix}
```

### Validate comment positions against the diff

**HARD RULE: Every inline comment must target a line that exists in the diff.**
Lines not in the diff (unchanged code, code from merge commits) will cause a
422 "Line could not be resolved" error from the GitHub API.

Before presenting comments, parse `gh pr diff` to build the set of commentable
lines:

```bash
gh pr diff {number} > /tmp/pr-diff.txt
```

Walk the diff output to extract every `(file_path, new_file_line_number)` pair
that appears in a hunk — both `+` (added) and ` ` (context) lines are valid
targets. `-` (removed) lines are not commentable on the `RIGHT` side.

For each proposed comment, check that `(path, line)` is in the commentable set:

- **Match found:** keep the comment as-is.
- **No match, nearby line (±5) in the same hunk matches:** move the comment to
  the nearest matching line.
- **No match at all:** convert to a file-level comment using
  `"subject_type": "file"` (omit `line` and `side`), or move the observation
  into the review body with a `file:line` reference.

### Present for approval

Show a numbered summary of all proposed comments:

```
1. [blocker] src/auth.ts:42 — Session token not invalidated on logout
2. [suggestion] src/utils.ts:18 — Consider renaming `processData` to something more specific
3. [praise] src/cache.ts:91 — Nice use of LRU eviction here
4. [question] src/api.ts:33 — Is this timeout intentional or a leftover from debugging?
```

Wait for the user to review. They may approve all, edit some, or skip
individual comments.

## Phase 6: Post Review

**HARD RULE: Never post the review on your own.** The user must always either:
1. Post the review themselves from GitHub, or
2. Explicitly confirm in the conversation that they want you to post it.

Do not assume consent. Do not infer consent from earlier instructions. Every
time you are about to post, ask first and wait for explicit confirmation.

### Present and wait

After presenting the comment summary, ask:
> "Here are the proposed review comments. You can:
> - Edit or skip individual comments
> - Post the review yourself from GitHub after I create it as pending
> - Tell me to 'post it' and I'll create the pending review for you
>
> What would you like to do?"

Wait for the user's explicit response before taking any action.

### Creating the pending review (only after user confirms)

Build the review payload and post via `gh api`:

**Important:** Do NOT include `"event": "PENDING"` in the payload — the REST
API rejects `PENDING` as an event value (422 error). Omitting `event` entirely
creates a pending (draft) review by default.

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "Reviewing with the help of {agent-name}, please let me know if it's annoying or noisy or not useful.",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**suggestion:** Consider extracting this into a helper — good candidate for a follow-up."
    }
  ]
}
EOF
```

Replace `{owner}/{repo}` with the actual repository, `{number}` with the PR
number, and `{agent-name}` with the name of the agent in use (e.g., "Claude
Code", "Cursor"). If unknown, use "an AI coding assistant."

The review stays **pending** (draft) — it is not visible to others until the
user clicks "Submit review" on GitHub or explicitly asks the agent to submit.

### After posting

Confirm success:
> "Pending review created with N comments. Go to {pr-url} to review and
> submit when ready."

Remind the user:
> "The `.review-playground/` directory has your experiments and test files.
> Feel free to keep exploring. Clean it up after the PR merges."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "review this PR" | Full 6-phase review, always asks before posting |
| "just investigate this PR" | Phases 1-4 only, no comments posted |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running playground experiments
