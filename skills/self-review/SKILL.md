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
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: opus
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.01-074735'
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

## HARD RULE: Pending review only

**Self-review is always a pending review** — multiple inline comments
batched under a single GitHub review that the user submits manually
after inspection. Never approximate this with direct
`gh api repos/.../pulls/{n}/comments` calls. The raw comments endpoint
publishes immediately and skips the human-in-the-loop checkpoint that
is the entire point of this skill.

This rule holds even when there is only one note to make. A single
design-note comment still goes through the pending-review flow. If you
catch yourself reaching for `gh api .../comments` (or any equivalent
that creates a published comment), stop — invoke this skill from the
top and let it stage the review via the `/pulls/{n}/reviews` endpoint
with the `event` field omitted (pending state).

A request phrased as "make a note in self-review" or "leave a quick
comment on the PR" is still a self-review and still goes through this
flow.

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

## Step 2.5: Reconcile against existing self-review

Before presenting proposed comments, fetch every review thread on the
PR authored by the PR author (i.e., prior self-review). On a
multi-round PR, the natural "what's new since last push" framing
makes it easy to restate rationale that's already on the PR — each
design decision should appear **exactly once**.

```bash
PR_NUM=$(gh pr view --json number --jq .number)
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
AUTHOR=$(gh pr view --json author --jq .author.login)

gh api graphql -f query='
  query($o:String!,$r:String!,$n:Int!){
    repository(owner:$o,name:$r){pullRequest(number:$n){
      reviewThreads(first:100){nodes{
        isResolved
        comments(first:100){nodes{path line body author{login}}}
      }}
    }}
  }' -F o="$OWNER" -F r="$REPO" -F n="$PR_NUM" \
  --jq --arg a "$AUTHOR" '
    .data.repository.pullRequest.reviewThreads.nodes[]
    | select(.comments.nodes[0].author.login == $a)
    | {resolved: .isResolved, c: .comments.nodes[0]}
    | {path: .c.path, line: .c.line, resolved, body: .c.body}'
```

For each proposed new comment, check the existing self-review threads
for **topical overlap** (same rationale, even on a different file or
line). On overlap:

- **Drop** the new comment if the prior note already says everything
  this one would, OR
- **Rewrite as a cross-reference** ("See related design note on
  `docs/specs/...:N`.") if the new location needs a pointer.

Resolve the prior thread only if its rationale is now **stale** —
never just because the new comment restates it.

Spec files are usually the canonical home for design rationale;
implementation-file notes should either add NEW context (tradeoff
specific to this site) or point at the spec.

## Step 2.6: Parallel-path completeness audit

Before any review comment is posted, scan for **sibling and
parallel code paths that may carry the same flaw** as anything
this PR fixed (or anything Step 2 found worth flagging).

A bug class rarely lives in a single line. Issues that recur per
location include credential redaction, input validation, error
handling, retry logic, fallback branches, guards, and
cleanup-on-error. When the diff fixes one instance, the next
review round (bot or human) almost always surfaces the same
class in the path the fix didn't touch — costing a separate
commit and review cycle for what should have been one fix.

For every change that fixes or flags a recurring-class issue,
run two scans:

1. **Same-file parallel branches** — the file's other code paths
   that perform the analogous operation:

   ```bash
   # For credential / stderr / error-output classes
   grep -n 'stderr\|2>&1\|>&2\|err\|error' <file>
   # For external calls of a kind
   grep -nE 'git (clone|fetch|push|remote)|curl|wget|http' <file>
   ```

2. **Sibling files in the same pipeline** — when shell scripts,
   modules, or services come in pairs / sets that share a
   contract:

   ```bash
   ls "$(dirname <fixed_file>)"/*.{sh,rb,py,ts,js} 2>/dev/null
   ```

   For each sibling, grep for the same pattern. Each hit is
   either (a) already correct, (b) doesn't have the analogous
   path, or (c) needs the same fix.

If category (c) appears, fold the parallel fix into **the same
commit** rather than deferring to a follow-up — single-round
review is the goal. The self-review comment that documents the
fix should list every path covered ("Applied at <path>:<line>,
<path>:<line>, …") so the reviewer doesn't have to reconstruct
the surface.

When a parallel path is genuinely unaffected (different contract,
defensive layer above, etc.), record that as a self-review
comment noting the audit was performed. Silence reads as "the
agent didn't look."

## Step 2.7: Verify code-comment claims against current implementation

Before posting any review comments, scan the diff for **inline code
comments and doc strings that make behavioral claims** about the
surrounding code, and mentally execute each claim against the
implementation that ships in this PR. A comment is correct only if
its claim is true given what the code actually does today, not given
what the code did when the comment was written.

Behavioral claims to flag for verification:

- "This makes X available" / "this enables Y"
- "Always works" / "is guaranteed to" / "never fails"
- "Required because" / "needed for" — the dependency must still hold
- Claims about subprocess, network, OS, or filesystem behavior that
  depend on flags, depths, modes, or environment that the
  implementation may have since narrowed
- Claims about what other code paths do (the comment names a
  function or behavior elsewhere that may have changed)

For each flagged comment:

1. Read the surrounding implementation in the current PR state.
2. Decide whether the claim is still true. If the implementation
   was narrowed (e.g., a deeper fetch became a shallower one, a
   recursive scan became flat, a guarded path became unguarded),
   the comment is likely stale.
3. If stale, **fix the comment in this PR** rather than leaving a
   review note about it — stale comments are documentation bugs,
   not design notes. Fold the fix into the same commit as the
   change that invalidated the comment if still possible, or add
   a comment-only fix commit on the same branch.
4. If the claim is still true but non-obvious, leave a self-review
   note pointing at the load-bearing detail so future readers
   know what holds the comment up.

This check runs independently of Step 2.6's parallel-path scan:
parallel-path looks for sibling instances of a fix; comment-accuracy
looks for stale narration of a behavior. Both fire on the same
trigger (the implementation changed) but cover different surfaces.

## Step 3: Present Comments for Approval

Show a numbered summary of proposed comments:

```
1. <module>/handler.ts:42 — Chose HMAC over RSA here because tokens are short-lived
2. <module>/store.ts:91 — This eviction strategy trades memory for latency
3. <module>/routes.ts:15 — Breaking change: removed deprecated v1 endpoint
```

Wait for user approval. They may edit, skip, or approve individual comments.

## Step 4: Post Comments

After user approves, create a PENDING review via GitHub API:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "commit_id": "{head_sha}",
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

Omit the `event` field to create a pending (draft) review — `"event": "PENDING"`
is not a valid enum value and returns HTTP 422. Valid event values (`APPROVE`,
`REQUEST_CHANGES`, `COMMENT`) are for *submitting* a review, not creating one.
Include `commit_id` set to the PR's HEAD SHA to anchor the review.

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

---

## Post-Completion

Invoke `wk:learn` with this skill's short name as the argument (e.g., `wk:learn self-review`).
