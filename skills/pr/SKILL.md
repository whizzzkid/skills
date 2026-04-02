---
name: wk:pr
description: >-
  Create a GitHub pull request and manage the post-PR workflow. Use when asked
  to create a PR, open a PR, push for review, or manage a stacked PR. Handles
  draft creation, stacking, CI polling, self-review, automated feedback, and
  marking ready.
argument-hint: '[optional: base branch for stacking]'
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
model:
  anthropic: sonnet
  openai: gpt-4.1-mini
  google: gemini-2.5-flash
  meta: llama-4-scout
  kimi: k2
  qwen: qwen3-30b
  cursor: composer-1.5
disable-model-invocation: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  effort: medium
---

# PR

Create and manage GitHub pull requests with draft mode, stacking support, and
a post-creation workflow that ensures quality before marking ready for review.

## Step 1: Assess Scope

Measure the change size to determine if stacking is needed:

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
git diff "${DEFAULT_BRANCH:-main}...HEAD" --stat
git diff "${DEFAULT_BRANCH:-main}...HEAD" --shortstat
```

- If the diff exceeds ~30 lines, ask the user if they want a stacked PR
- If borderline or unclear, ask the user's preference
- Determine the base branch (`main`, `master`, or a previous PR branch)

## Step 2: Create Draft PR

**Always create PRs in draft mode** (`--draft` flag). Never create a non-draft
PR unless the user explicitly asks.

### Simple PR

```bash
gh pr create --draft --title "feat(scope): ✨ description" --body "$(cat <<'EOF'
## Summary
- What changed and why

## Test plan
- [ ] How to verify the changes

EOF
)"
```

PR titles use the same conventional commit + emoji scheme as commit messages.

### Stacked PR

When splitting work into stacked PRs:

- Append `[Part X/Y]` at the end of the PR title
- Base each PR on the previous one: `--base previous-branch`
- Each PR must pass CI in isolation — no forward dependencies
- Example: `feat(auth): ✨ add OAuth2 login [Part 1/3]`

```bash
gh pr create --draft --base previous-branch \
  --title "feat(scope): ✨ description [Part X/Y]" \
  --body "$(cat <<'EOF'
## Summary
- What changed and why

## Stack
- Part 1: #PR_NUMBER (merged/open)
- **Part 2: this PR**
- Part 3: pending

## Test plan
- [ ] How to verify the changes

EOF
)"
```

## Step 3: Post-Creation Workflow

After the draft PR is created (or after pushing new commits to an existing PR):

1. **Update PR description** — Review the existing description to ensure it
   still covers all changes. If it has drifted, update with `gh pr edit`.
2. **Poll CI** — Launch a background polling job (using the pass-the-build
   agent if available) to wait for all build steps to pass. Do not proceed
   while CI is failing.

## Step 4: Once CI is Green

1. **Invoke `wk:self-review`** to post design-decision comments on the PR.
   This documents non-obvious choices and critical context for human reviewers.

2. **Address automated review feedback** — Fetch existing review comments from
   automated tools:

   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   gh pr reviews
   ```

   Present these as a numbered list with a suggested fix for each. Ask the
   user: "How would you like to handle these automated review comments?"
   Wait for the user's response before proceeding.

## Step 5: Mark Ready

After the self-review is posted and automated feedback is addressed:

```bash
gh pr ready
```

Confirm to the user:
> "PR #{number} is marked ready for review: {url}"

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "create a PR" | Full workflow: draft → CI → self-review → ready |
| "stack this PR" | Stacked PR with `[Part X/Y]` and `--base` |
| "mark PR ready" | Skip to step 5 |
| New commits pushed | Re-run from step 3 (update description, re-poll CI) |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
