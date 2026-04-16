---
name: wk:pr-resolve
description: >-
  Address PR review comments interactively — resolve feedback from reviewers by
  implementing fixes, preparing response comments, and managing the full
  resolution cycle. Use when asked to resolve PR comments, address review
  feedback, fix PR issues, respond to reviewers, or handle PR conversations.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git fetch:*)"
  - "Bash(git merge:*)"
  - "Bash(git rebase:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(git status:*)"
  - "Bash(git add:*)"
  - "Bash(git commit:*)"
  - "Bash(git push:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git symbolic-ref:*)"
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - AskUserQuestion
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.2.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
and manage the full resolution cycle from sync to summary.

## Hard Rules

1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
3. **Only resolve threads you actually worked on.** A thread is resolvable
   only if a fix was applied (option a/b) or a bot comment was explicitly
   dismissed (option d). Never resolve follow-up questions (c), skipped
   threads (e), or self-review threads.
4. **Never force-push.** Use regular `git push` only.
5. **Never commit without attempting verification** (build/lint/test). If
   verification is unavailable or fails, inform the user before proceeding.
6. **Commits follow `wk:commit` conventions** — conventional format with
   emoji, signed commits, HEREDOC for messages. Never use `--no-gpg-sign`.
7. **One commit per resolved comment.** Each triaged comment gets its own
   commit so reviewers can trace exactly which commit addresses which
   comment. Never bundle multiple comments into one commit. Push only
   once at the end (Step 8) to avoid triggering multiple CI builds.
8. **Exclude self-review comments.** Never triage, suggest fixes for, or
   resolve threads where the root comment was authored by the PR owner.
   These are the author's own notes and are not reviewer feedback.
9. **Include bot reviews.** Treat comments from bot accounts (Copilot,
   GitHub Actions, custom bots) as first-class review feedback. Triage
   them alongside human reviewer comments — evaluate each for correctness
   before accepting or dismissing.

## Step 1: Identify the PR

Determine the PR under review:

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,headRefOid
```

If on main/master or no PR is detected, ask the user for a PR number or URL.
Extract `{owner}`, `{repo}`, `{number}`, `{base_branch}`, and `{head_sha}`.

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

## Step 2: Sync Branch

Ensure the branch is up to date with the base branch:

```bash
git fetch origin
git merge origin/{base_branch} --no-edit
```

If the merge produces conflicts:
1. List conflicted files with `git status`
2. Present to the user and ask how to resolve
3. Do not proceed until the working tree is clean

If already up to date, confirm:
> "Branch is up to date with `{base_branch}`."

## Step 3: Fetch Unresolved Comments

Combine GraphQL (for thread resolution status) and REST (for full comment
data) to build a map of active, unresolved review threads.

### Identify the PR author

Extract the PR author login from the `gh pr view` output (Step 1). This is
used to **exclude self-review comments** — threads where the root comment
was authored by the PR owner are skipped entirely.

### GraphQL — thread resolution status and IDs

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        author { login }
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 100) {
              nodes { id databaseId body path line author { login } }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F number={number}
```

### REST — full comment details

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, user_type: .user.type, author_association: .author_association, updated_at, in_reply_to_id}'
```

Note: `user_type` distinguishes humans (`User`) from bots (`Bot`).
`author_association` shows the commenter's relationship to the repo.

### Classify comment authors

For each comment, classify the author:

| `user_type` | Pattern | Classification |
|-------------|---------|----------------|
| `Bot` | `*[bot]` suffix (e.g., `copilot[bot]`, `github-actions[bot]`) | **Bot review** |
| `Bot` | Custom bot names without `[bot]` suffix | **Bot review** |
| `User` | Matches PR author login | **Self-review** (skip) |
| `User` | Any other login | **Reviewer** |

### Build the comment map

For each GraphQL thread node:
- **Skip** if `isResolved == true`
- **Skip** if the root comment author matches the PR author login
  (self-review) — do not include self-review comments in the triage
- Match thread comments to REST comments by `databaseId == id`
- Extract root comment (no `in_reply_to_id`) and its reply chain
- Record: `{threadId, commentId, path, line, body, user, userType, replies[], isOutdated}`
- Tag threads where the root comment author is a bot (`isBot: true`)

### Filter active comments

A comment is **active** if:
- Thread is NOT resolved (`isResolved == false`)
- Root comment is NOT from the PR author (not self-review)
- Thread is NOT outdated (`isOutdated == false`), OR if outdated, the
  underlying concern is still present in the current code (verify by reading
  the file at the referenced path and line)

Skip truly outdated comments where the code has been rewritten and the
concern no longer applies. Note these as "auto-skipped" in the summary.

### Group by file

Sort active comments by file path, then by line number within each file.
Separate bot comments from human reviewer comments in the summary:

> "Found X unresolved comments across Y files (Z auto-skipped as outdated,
> S skipped as self-review)."
>
> **Bot reviews:**
> **src/auth.ts** (2 comments from copilot[bot])
>
> **Reviewer comments:**
> **src/auth.ts** (1 comment from @reviewer1)
> **src/api.ts** (1 comment from @reviewer2)
> **src/utils.ts** (2 comments from @reviewer1)

## Step 4: Generate Suggestions

Process bot reviews first (they often flag actionable issues like style
violations, security concerns, or code suggestions), then human reviewer
comments.

For each active comment, in file-grouped order:

1. Read the full file (not just the diff hunk) to understand context
2. Read the reviewer's comment and full reply chain
3. Analyze what the reviewer is asking for
4. Generate a concrete suggested fix — actual code changes, not vague advice

### Bot review handling

Bot comments (Copilot, custom bots, CI bots) often include:
- **Code suggestions** (Copilot): Extract the suggested diff and present it
  as a concrete fix. Evaluate whether the suggestion is correct before
  recommending it — bots can be wrong.
- **Lint / style violations**: Map the violation to a specific fix.
- **Security warnings**: Treat seriously — read the flagged code and verify
  the concern. If valid, propose a fix. If a false positive, draft a
  dismissal reply explaining why.
- **Automated analysis**: Summarize the bot's finding and propose an action.

Do NOT blindly accept bot suggestions. Evaluate each one for correctness.

### Suggestion format

Present each suggestion as:

```
### Comment {n}/{total}: {path}:{line}
**Reviewer:** @{user} {bot_badge}
**Comment:** {body}
**Reply chain:** {summary of any replies, or "none"}

**Suggested fix:**
{Description of what to change and why}

{Code diff or snippet showing the proposed change}
```

Where `{bot_badge}` is `🤖 (bot)` if the commenter is a bot, omitted
otherwise.

## Step 5: Present and Collect Decisions

Present suggestions **one at a time**. For each, ask the user:

> How would you like to handle this?
> **(a)** Apply the suggested fix
> **(b)** Do something different (describe what you want)
> **(c)** Ask the reviewer a follow-up question
> **(d)** Dismiss — not applicable / false positive (bot reviews only)
> **(e)** Skip — leave as-is without resolving

### Handle each response type

**(a) Apply suggested fix:**
- Apply the edit using the `Edit` tool
- Track in `fixes_to_commit` list: `{path, line, description, threadId, commentId}`
- Draft a reply: "Fixed in {commit_ref} — {brief explanation}"
- Track in `resolve_after_push` list

**(b) Different fix:**
- Ask: "What would you like to do instead?"
- Apply the user's approach
- Track in `fixes_to_commit` list
- Draft a reply based on the actual fix applied
- Track in `resolve_after_push` list

**(c) Follow-up question:**
- Ask: "What would you like to ask the reviewer?"
- Draft the question as a reply comment
- Track in `reply_only` list — **do NOT add to resolve list**

**(d) Dismiss (bot reviews only):**
- Draft a reply explaining why the suggestion was dismissed
  (e.g., "False positive — {reason}" or "Not applicable — {reason}")
- Track in `resolve_after_push` list (dismissed bot comments should be
  resolved to reduce noise)

**(e) Skip:**
- Do not apply any fix, post any reply, or resolve the thread
- Track in `skipped` list — the thread stays open and untouched
- Use this for comments the user wants to handle later or outside this session

After each decision, move to the next comment. Do not batch decisions.

## Step 6: Verify and Commit

After all comments in a file (or logical group) are processed:

### Verify the fix

Detect the project's verification command and run a quick check:

```bash
# Try common build/lint commands (use first found)
[ -f package.json ] && npm run lint --if-present 2>&1 | tail -20
[ -f Makefile ] && make check 2>&1 | tail -20
[ -f Cargo.toml ] && cargo check 2>&1 | tail -20
```

If verification fails, present the error and ask:
> "Verification failed. Would you like to (a) fix the issue, (b) commit
> anyway, or (c) skip this fix?"

If no build system is detected, warn:
> "No build/lint command detected — skipping verification. Please verify
> manually after we finish."

### Commit (one per resolved comment)

After each individual comment is resolved (option a, b, or d), immediately
stage and commit the fix. This creates a 1:1 mapping between commits and
review comments, making it easy for reviewers to trace each fix.

```bash
git add {files}
git commit -m "$(cat <<'EOF'
fix(scope): 🐛 {brief description of what this comment asked for}

Addresses review comment by @{reviewer} on {path}:{line}

Co-Authored-By: {agent-name} <noreply@example.com>
EOF
)"
```

Use the commit type that matches the nature of the change: `fix` for bug
fixes, `refactor` for restructuring, `feat` for new behavior. Always
include the emoji per `wk:commit` conventions.

Record the commit SHA for each fix — it will be referenced in the reply
comment (e.g., "Fixed in `abc1234`"). Draft the reply with the real SHA
now, not a placeholder.

**Do NOT push after each commit.** All commits are pushed together in
Step 8 as a single `git push`, so only one CI build is triggered.

## Step 7: Confirm Everything

After ALL comments are processed, present a full summary:

```
## Resolution Summary

### Fixes applied ({count} commits)
1. abc1234 — fix(auth): 🐛 invalidate session on logout
   - Addresses: @reviewer src/auth.ts:42, src/auth.ts:58

2. def5678 — refactor(api): ♻️ extract timeout config
   - Addresses: @reviewer2 src/api.ts:33

### Bot reviews addressed ({count})
3. src/auth.ts:15 — copilot[bot]: applied suggested null check
4. src/api.ts:22 — copilot[bot]: dismissed (false positive)

### Reply comments to post ({count})
1. src/auth.ts:42 → "Fixed in abc1234 — session now invalidated on logout"
2. src/api.ts:33 → "Extracted to config — timeout is now configurable"
3. src/auth.ts:15 → "Applied — added null check as suggested"
4. src/api.ts:22 → "False positive — value is guaranteed non-null by L18"

### Follow-up questions ({count})
5. src/utils.ts:18 → "Could you clarify whether you mean..."

### Threads to resolve ({count})
- src/auth.ts:42, src/auth.ts:58, src/api.ts:33, src/auth.ts:15, src/api.ts:22

### Threads left open ({count})
- src/utils.ts:18 (follow-up question)
- src/models.ts:9 (skipped)

### Self-review threads excluded ({count})
- src/config.ts:5, src/config.ts:12 (PR author's own comments — not touched)
```

**Resolution rule:** Only threads in `resolve_after_push` are resolved.
A thread lands in that list **only** when a fix was applied (a/b) or a bot
comment was explicitly dismissed (d). Threads with follow-up questions (c),
skipped threads (e), and self-review threads are **never** resolved.

Ask:
> "Does this look correct? I will push {N} commits, post {M} reply comments,
> resolve {R} threads, and leave {L} threads open for follow-up.
> Proceed? (yes / edit / abort)"

Wait for explicit confirmation. If "edit," ask what to change. If "abort,"
stop without pushing or posting anything.

## Step 8: Push and Respond

**Only after explicit user confirmation.**

### Push commits

```bash
git push
```

If push is rejected, tell the user and ask how to proceed. Never force-push.

### Force-push warning

If the branch was force-pushed earlier in this session (e.g., after a
rebase in Step 2), GitHub may have invalidated existing review comment
threads. Replies to invalidated threads will return **404 Not Found**.
This is expected and non-fatal — log the failure and continue with the
remaining replies.

### Post reply comments (sequentially)

Post replies **one at a time, in order**. Do NOT post in parallel — a
404 on one reply must not cancel the remaining replies.

For each drafted reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"
```

If the API returns **404**:
- Log: "Reply to comment {comment_id} on {path}:{line} returned 404
  (thread likely invalidated by force-push). Skipping."
- Remove the corresponding thread from `resolve_after_push` (cannot
  resolve a thread that no longer exists)
- Continue with the next reply

If the API returns any other error, report it to the user and ask how
to proceed.

### Resolve threads

For each thread in `resolve_after_push` (NOT in `reply_only`):

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_id}"
```

If resolution returns an error (thread invalidated), log and continue.

**HARD RULE: Never resolve threads in the `reply_only` list.** Those have
follow-up questions and must stay open for the reviewer to respond.

Report progress as each action completes.

## Step 9: Check Merge Conflicts

After pushing, verify no merge conflicts with the base branch:

```bash
git fetch origin
git merge --no-commit --no-ff origin/{base_branch} 2>&1
```

If clean:

```bash
git merge --abort 2>/dev/null  # clean up the test merge
```

> "No merge conflicts with `{base_branch}`. You're clear."

If conflicts are detected:

```bash
git merge --abort
```

> "Merge conflicts detected with `{base_branch}` in: {file list}.
> Would you like me to resolve them now?"

## Step 10: Final Summary

Present a concise summary of everything done:

```
## PR #{number} Review Resolution Complete

**Branch synced:** ✓ Up to date with `{base_branch}`
**Comments processed:** {total} of {total_found}
**Self-review excluded:** {count} (PR author's own comments)
**Bot reviews handled:** {count} ({applied} applied, {dismissed} dismissed)
**Reviewer fixes:** {count}
**Commits pushed:** {count} ({commit_list})
**Replies posted:** {count}
**Threads resolved:** {count} (only threads with applied fixes or dismissed bots)
**Threads left open:** {count} (follow-ups: {f}, skipped: {s})
**Merge conflicts:** None / {details}

PR URL: {url}
```

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "resolve PR comments" | Full 10-step workflow |
| "address review feedback" | Full 10-step workflow |
| "fix PR #{number}" | Full workflow for specific PR |
| "respond to reviewers" | Full workflow with focus on replies |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running verification commands
- Commit signing configured (GPG or SSH)
