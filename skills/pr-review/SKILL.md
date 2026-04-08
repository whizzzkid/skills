---
name: wk:pr-review
description: >-
  Thorough, critical code review of a GitHub pull request. Use when asked to
  review a PR, review code changes, help review this PR, create review comments,
  or investigate a pull request. Builds a playground to validate assumptions,
  runs experiments, and creates pending review comments via GitHub API.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr checkout:*)"
  - "Bash(gh api repos:*)"
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
disable-model-invocation: true
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

Collect and internalize:
- PR title, description, and linked issues
- Full diff: `gh pr diff`
- List of changed files and their scope
- Commit history on this branch
- The base branch to understand what's being merged into

Before moving on, announce what you found:
> "Reviewing PR #N: *title* — X files changed, Y commits. Base: `main`. Let me dig in."

## Phase 2: Investigation

Read every changed file in full — not just the diff hunks. Understand the
surrounding code, call sites, downstream consumers, and existing test coverage.

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

## Phase 3: Playground

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

## Phase 4: Review Comments

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

## Phase 5: Post Review

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

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "Reviewing with the help of {agent-name}, please let me know if it's annoying or noisy or not useful.",
  "event": "PENDING",
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
| "review this PR" | Full 5-phase review, always asks before posting |
| "just investigate this PR" | Phases 1-3 only, no comments posted |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running playground experiments
