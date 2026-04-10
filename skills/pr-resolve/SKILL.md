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
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
and manage the full resolution cycle from sync to summary.

## Hard Rules

1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
3. **Never resolve threads marked for follow-up questions.** Only resolve
   threads where a fix was applied and the user confirmed the response.
4. **Never force-push.** Use regular `git push` only.
5. **Never commit without attempting verification** (build/lint/test). If
   verification is unavailable or fails, inform the user before proceeding.
6. **Commits follow `wk:commit` conventions** — conventional format with
   emoji, signed commits, HEREDOC for messages. Never use `--no-gpg-sign`.
7. **One logical fix per commit.** Group related comments into a single
   commit when they address the same concern. Never bundle unrelated fixes.

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

### GraphQL — thread resolution status and IDs

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
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
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

### Build the comment map

For each GraphQL thread node:
- **Skip** if `isResolved == true`
- Match thread comments to REST comments by `databaseId == id`
- Extract root comment (no `in_reply_to_id`) and its reply chain
- Record: `{threadId, commentId, path, line, body, user, replies[], isOutdated}`

### Filter active comments

A comment is **active** if:
- Thread is NOT resolved (`isResolved == false`)
- Thread is NOT outdated (`isOutdated == false`), OR if outdated, the
  underlying concern is still present in the current code (verify by reading
  the file at the referenced path and line)

Skip truly outdated comments where the code has been rewritten and the
concern no longer applies. Note these as "auto-skipped" in the summary.

### Group by file

Sort active comments by file path, then by line number within each file.
Present a summary:

> "Found X unresolved comments across Y files (Z auto-skipped as outdated)."
>
> **src/auth.ts** (3 comments)
> **src/api.ts** (1 comment)
> **src/utils.ts** (2 comments)

## Step 4: Generate Suggestions

For each active comment, in file-grouped order:

1. Read the full file (not just the diff hunk) to understand context
2. Read the reviewer's comment and full reply chain
3. Analyze what the reviewer is asking for
4. Generate a concrete suggested fix — actual code changes, not vague advice

### Suggestion format

Present each suggestion as:

```
### Comment {n}/{total}: {path}:{line}
**Reviewer:** @{user}
**Comment:** {body}
**Reply chain:** {summary of any replies, or "none"}

**Suggested fix:**
{Description of what to change and why}

{Code diff or snippet showing the proposed change}
```

## Step 5: Present and Collect Decisions

Present suggestions **one at a time**. For each, ask the user:

> How would you like to handle this?
> **(a)** Apply the suggested fix
> **(b)** Do something different (describe what you want)
> **(c)** Ask the reviewer a follow-up question

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

### Commit

Stage and commit using `wk:commit` conventions:

```bash
git add {files}
git commit -m "$(cat <<'EOF'
fix(scope): 🐛 address review feedback — {brief description}

{Optional body listing what was fixed and which comments it addresses}

Co-Authored-By: {agent-name} <noreply@example.com>
EOF
)"
```

Use the commit type that matches the nature of the change: `fix` for bug
fixes, `refactor` for restructuring, `feat` for new behavior. Always
include the emoji per `wk:commit` conventions.

Group related fixes into one commit. Unrelated fixes across different files
get separate commits.

## Step 7: Confirm Everything

After ALL comments are processed, present a full summary:

```
## Resolution Summary

### Fixes applied ({count} commits)
1. abc1234 — fix(auth): 🐛 invalidate session on logout
   - Addresses: @reviewer src/auth.ts:42, src/auth.ts:58

2. def5678 — refactor(api): ♻️ extract timeout config
   - Addresses: @reviewer src/api.ts:33

### Reply comments to post ({count})
1. src/auth.ts:42 → "Fixed in abc1234 — session now invalidated on logout"
2. src/api.ts:33 → "Extracted to config — timeout is now configurable"

### Follow-up questions ({count})
3. src/utils.ts:18 → "Could you clarify whether you mean..."

### Threads to resolve ({count})
- src/auth.ts:42, src/auth.ts:58, src/api.ts:33

### Threads left open ({count})
- src/utils.ts:18 (follow-up question)
```

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

### Post reply comments

For each drafted reply, post as a reply to the original review comment:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"
```

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
**Commits pushed:** {count} ({commit_list})
**Replies posted:** {count}
**Threads resolved:** {count}
**Threads left open:** {count} (follow-up questions)
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
