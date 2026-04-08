---
name: wk:self-review
description: >-
  Post inline self-review comments on your own PR to document design decisions,
  non-obvious choices, and critical context for human reviewers. Use when a PR
  is ready for self-review, after CI passes, or when wk:pr invokes this skill.
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh api repos:*)"
  - Read
  - Grep
  - Glob
  - AskUserQuestion
model: opus
effort: medium
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

# Self-Review

Post inline review comments on your own PR to help human reviewers understand
design decisions, non-obvious logic, and critical context. This is not an
adversarial bug hunt — it's documentation for reviewers.

## Step 1: Gather Context

Get the PR details and full diff:

```bash
gh pr view --json number,title,url,baseRefName,headRefName
gh pr diff
```

Read every changed file in full — not just the diff hunks. Understand what
changed, why it changed, and what alternatives existed.

## Step 2: Identify Comment-Worthy Changes

**DO comment on:**

- New logic and non-obvious decisions
- Security-sensitive code paths
- Behavioral changes and potential gotchas
- Design decisions where alternatives were rejected
- Performance implications that aren't obvious from the diff
- Tradeoffs accepted (and why)

**Do NOT comment on:**

- Formatting or linting fixes
- Renames or structural moves
- Boilerplate or configuration
- Anything a reviewer can understand at a glance

The goal is signal, not noise. Fewer high-quality comments beat many trivial
ones.

## Step 3: Present Comments for Approval

Show a numbered summary of proposed comments:

```
1. src/auth.ts:42 — Chose HMAC over RSA here because tokens are short-lived
2. src/cache.ts:91 — This eviction strategy trades memory for latency
3. src/api.ts:15 — Breaking change: removed deprecated v1 endpoint
```

Wait for user approval. They may edit, skip, or approve individual comments.

## Step 4: Post Comments

After user approves, create a PENDING review via GitHub API:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "event": "PENDING",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "Design note: chose X over Y because..."
    }
  ]
}
EOF
```

The review stays **pending** (draft) until the user submits it on GitHub.

## Updating an Existing Self-Review

When new commits are pushed to a PR that already has self-review comments:

1. **Resolve stale comments** that no longer apply — use `gh api` to resolve
   review threads or delete outdated comments
2. **Add new comments** for any critical changes introduced by the new commits
3. Present the updated comment set for approval before posting

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Invoked by `wk:pr` | Full self-review flow after CI passes |
| "self-review this PR" | Manual invocation on current PR |
| New commits pushed | Update existing comments, resolve stale ones |
