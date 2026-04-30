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
  version: '2026.04.30-210212'
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

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/self-review"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/self-review/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:self-review
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `self-review/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
