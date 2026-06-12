---
name: wk-self-review
description: >-
  Post inline self-review comments on your own PR to document design decisions,
  non-obvious choices, and critical context for human reviewers. Use when a PR
  is ready for self-review, after CI passes, or when wk-pr invokes this skill.
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh api repos:*)"
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Write
  - Skill
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.06.12-021632'
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

## GitHub interaction routing

**HARD RULE:** All GitHub reads and writes in this skill follow
`wk-gh`:

- Read-side: org scoping per `wk-gh` Step 1–2.
- Write-side: append the canonical outbound footer per `wk-gh`
  Step 4 to every inline comment body posted via the pending
  review. Inject at payload-render time so no `comments[]` entry
  ships footer-less.

## Pending review only

**HARD RULE:** Self-review is always a pending review — multiple inline comments
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

## Step 0: Route GitHub I/O through `wk-gh` (MANDATORY)

Invoke `wk-gh` before any `gh` command or GitHub API call issued
by this skill. Do not proceed to Step 1 until `wk-gh` confirms org
scoping and the canonical outbound footer is staged for the
payload-render step.

```
Skill(wk-gh)
```

- Skipping this step violates the GitHub-routing HARD RULE above —
  posts ship without org scoping and without the canonical footer.
- The prose HARD RULE alone does not gate execution; this numbered
  step does. Treat Step 0 as a precondition for Step 1, not advice.

## Step 0.5: Pre-flight the pending-review POST permission

The pending review is created with a `POST` to
`repos/{owner}/{repo}/pulls/{n}/reviews` under the user's identity.
In auto mode the permission classifier blocks GitHub writes that lack
an explicit allow rule — and it blocks at Step 4, after the payload is
built, wasting the work.

- Check whether the write permission is already granted before building
  the payload:

  ```bash
  grep -rE 'gh api repos/.*/pulls/.*/reviews' ~/.claude/settings.json .claude/settings*.json 2>/dev/null
  ```

- If no match, surface a one-line prompt to add it, then proceed (the
  classifier still gates the actual POST — this just warns early):

  > Self-review posts a pending review via
  > `gh api repos/*/pulls/*/reviews` (POST). Add that to allowed Bash
  > commands to avoid a mid-flow block.

- Never downgrade to a published `.../comments` call to dodge the
  prompt — that violates the pending-review HARD RULE above.

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

### Markdown preview link for large diffs

When a changed file has a `.md` extension and the diff adds >50 lines,
stage an inline comment on the first in-hunk line of that file:

> Rendered preview — easier to read than the diff for large markdown changes:
> `https://github.com/{owner}/{repo}/blob/{branch}/{path}`

- Resolve `{branch}` from `gh pr view --json headRefName --jq .headRefName`.
- Snap `line` to a hunk-valid position per Step 3.5 before POSTing.

### Architecture-level change → invoke [`wk-arch-review`](../arch-review/README.md)

When the diff introduces or alters the project's architecture, run
`wk-arch-review` first and use its findings to seed self-review context — the
human reviewer needs the design rationale and known gotchas up front.

- **Trigger when any holds:**
  - A changed path is an architecture/design doc — case-insensitive match on
    `docs/(specs|adr|arch|design|rfc)/`, or a filename containing
    `architecture`, `design`, `spec`, `rfc`, `adr`, `hld`, `lld`, or `tech-spec`.
  - The diff introduces infrastructure/topology change (new service, datastore,
    queue, cache, external dependency, IaC), a trust-boundary/auth change, a
    public API/contract change, or a migration that reshapes data ownership.
- **Invoke** (changed doc path when one changed, else the PR):

  ```
  Skill(wk-arch-review, args="<changed-doc-path | PR number>")
  ```

- Fold the result in: post a top-level self-review note linking the design
  rationale, and add inline comments on the components arch-review flagged
  (SPOFs, unhappy paths, risky assumptions) so reviewers see them in context.
- Skip silently when no trigger matches.

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
```

Use the canonical query from `skills/pr-resolve/references/graphql-review-threads.md`
with `-F o="$OWNER" -F r="$REPO" -F n="$PR_NUM"`, then pipe through jq to filter
by author and extract the fields needed:

```bash
# pipe the GraphQL result through jq
jq --arg a "$AUTHOR" '
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

**Approach-pivot thread audit.** When new commits change a feature's
logical approach (the wk-workflow design-pivot trigger), audit existing
self-review threads independently of any new proposed comment — a pivot
leaves a thread that silently contradicts the new code even when nothing
new is being said about that path.

- Fetch unresolved self-review threads on the changed files.
- Flag any whose rationale describes the **old** approach (e.g., explaining
  serialization after a switch to parallel execution).
- Resolve each stale thread and repost updated rationale anchored to the
  new commit. Treat "approach changed, self-review not updated" exactly as a
  stale code comment.

Spec files are usually the canonical home for design rationale;
implementation-file notes should either add NEW context (tradeoff
specific to this site) or point at the spec.

## Step 2.6: Parallel-path completeness audit

Before posting comments, scan for sibling and parallel code paths that carry the same flaw as anything this PR fixed or flagged. A bug class rarely lives in a single line — credential redaction, input validation, error handling, retry logic, guards, and cleanup-on-error recur across sibling paths.

For every recurring-class fix, run two scans:

1. **Same-file parallel branches:**
   ```bash
   grep -n 'stderr\|2>&1\|>&2\|err\|error' <file>
   grep -nE 'git (clone|fetch|push|remote)|curl|wget|http' <file>
   ```

2. **Sibling files in the same pipeline:**
   ```bash
   ls "$(dirname <fixed_file>)"/*.{sh,rb,py,ts,js} 2>/dev/null
   ```
   For each sibling, grep for the same pattern.

If a sibling path needs the same fix, fold it into **the same commit** — single-round review is the goal. List every path covered in the self-review comment. If a path is genuinely unaffected, note the audit was performed — silence reads as "the agent didn't look."

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

## Step 3: Present Comments

Show a numbered summary of proposed comments:

```
1. <module>/handler.ts:42 — Chose HMAC over RSA here because tokens are short-lived
2. <module>/store.ts:91 — This eviction strategy trades memory for latency
3. <module>/routes.ts:15 — Breaking change: removed deprecated v1 endpoint
```

**HARD RULE — never ask "want me to post this?".** Posting the pending
(draft) review is unconditional after the summary; GitHub's Submit
button is the human checkpoint, not a terminal prompt. The user can
opt out by saying "don't post" / "wait" / "let me edit first" before
the summary is presented. After the summary, proceed directly to
Step 4 — no confirmation round-trip.

## Step 3.5: Validate every comment line lies inside a diff hunk

**HARD RULE:** Before POSTing, verify each comment's `line` falls
inside a `@@` hunk range in `git diff <base>...HEAD -- <path>`. The
API rejects out-of-hunk lines with `422 "Line could not be resolved"`.

- Resolve `<base>` dynamically: `gh pr view --json baseRefName --jq .baseRefName`.
- Extract `+N,M` ranges from each `@@` header for the file; the
  commentable set is the union of `[N, N+M-1]` per hunk on the new-file side.
- For each proposed comment, check `line ∈ commentable_set`. If not:
  - Snap to the nearest in-hunk line, **or**
  - Convert to a file-level comment by omitting both `line` and
    `side` in the API payload.
- Absolute file line numbers from `Read` output are not commentable
  unless they also appear in a diff hunk — never assume the two are
  the same.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" -- "$PATH_TO_FILE" \
  | grep -E '^@@' | sed -E 's/.*\+([0-9]+),?([0-9]*).*/\1 \2/'
```

## Step 4: Post Comments

Post the pending review immediately after Step 3's summary — no
approval prompt. Create a PENDING review via GitHub API:

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
| Invoked by `wk-pr` | Full self-review flow after CI passes |
| "self-review this PR" | Manual invocation on current PR |
| New commits pushed | Update existing comments, resolve stale ones |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn self-review`).
