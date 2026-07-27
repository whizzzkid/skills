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
  version: '2026.07.27-203326'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Review

Post inline review comments on your own PR → help human reviewers understand
design decisions, non-obvious logic, critical context. Not an adversarial bug
hunt — documentation for reviewers.

## GitHub interaction routing

**HARD RULE:** All GitHub reads/writes follow `wk-gh`:

- Read-side: org scoping per `wk-gh` Step 1–2.
- Write-side: append canonical outbound footer per `wk-gh` Step 4 to every
  inline comment body posted via the pending review. Inject at payload-render
  time → no `comments[]` entry ships footer-less.

## Pending review only

**HARD RULE:** Self-review is always a pending review — multiple inline comments
batched under a single GitHub review the user submits manually after inspection.

- Never use direct `gh api repos/.../pulls/{n}/comments`. The raw comments
  endpoint publishes immediately → skips the human-in-the-loop checkpoint that
  is the entire point of this skill.
- Holds even for a single note. One design-note comment still goes through the
  pending-review flow.
- If reaching for `gh api .../comments` (or any equivalent that publishes), stop
  → invoke this skill from the top → stage via `/pulls/{n}/reviews` with `event`
  omitted (pending state).
- "make a note in self-review" / "leave a quick comment on the PR" → still a
  self-review, still goes through this flow.

## Step 0: Route GitHub I/O through `wk-gh` (MANDATORY)

Invoke `wk-gh` before any `gh` command or GitHub API call. Do not proceed to
Step 1 until `wk-gh` confirms org scoping + canonical outbound footer staged for
payload-render.

```
Skill(wk-gh)
```

- Skipping violates the GitHub-routing HARD RULE → posts ship without org
  scoping and without the canonical footer.
- The prose HARD RULE does not gate execution; this numbered step does. Step 0
  is a precondition for Step 1, not advice.

## Step 0.5: Pre-flight the pending-review POST permission

Pending review created via `POST repos/{owner}/{repo}/pulls/{n}/reviews` under
the user's identity. In auto mode the permission classifier blocks GitHub writes
lacking an explicit allow rule — and blocks at Step 4, after the payload is
built → wastes the work.

- Check the write permission before building the payload:

  ```bash
  grep -rE 'gh api repos/.*/pulls/.*/reviews' $HOME/.claude/settings.json .claude/settings*.json 2>/dev/null
  ```

- No match → surface a one-line prompt, then proceed (classifier still gates the
  actual POST — this only warns early):

  > Self-review posts a pending review via
  > `gh api repos/*/pulls/*/reviews` (POST). Add that to allowed Bash
  > commands to avoid a mid-flow block.

- Never downgrade to a published `.../comments` call to dodge the prompt →
  violates the pending-review HARD RULE.
- On a blocked POST, preserve the work: write the composed payload with the
  **Write tool** to `/tmp/agent/gh/<owner>/<repo>/pulls/{n}/self-review.json`,
  then hand the user a one-line `gh api … --input <file>` to post it. Never
  rebuild the payload in a bash command that mentions the blocked endpoint
  (`gh api repos/*/pulls/*/reviews`) — the classifier matches command text, not
  execution, so even a `jq … > file.json` write re-trips the same denial.

## Step 1: Gather Context

```bash
gh pr view --json number,title,url,baseRefName,headRefName
gh pr diff
```

Read every changed file in full — not just diff hunks. Understand what changed,
why, and what alternatives existed.

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

Goal is signal, not noise. Fewer high-quality comments beat many trivial ones.

**HARD RULE — never fabricate a quantitative claim.** A comment that justifies a
threshold (timeout, buffer size, retry count, dimension) with a specific size,
latency, or performance figure must cite a verifiable source (a benchmark,
release artifact, CI log, or measurement in the repo) or state the value is
conservative without inventing a number. A plausible-sounding figure with no
source behind it is fabrication — drop the number, keep the rationale.
"Conservative for any reasonable response" is honest; an invented range is not.

### Markdown preview link for large diffs

Changed file with `.md` extension AND diff adds >50 lines → stage an inline
comment on the first in-hunk line of that file:

> Rendered preview — easier to read than the diff for large markdown changes:
> `https://github.com/{owner}/{repo}/blob/{branch}/{path}`

- Resolve `{branch}` from `gh pr view --json headRefName --jq .headRefName`.
- Snap `line` to a hunk-valid position per Step 3.5 before POSTing.

### Architecture-level change → invoke [`wk-arch-review`](../arch-review/README.md)

Diff introduces/alters the project's architecture → run `wk-arch-review` first,
seed self-review context with its findings. Human reviewer needs design
rationale + known gotchas up front.

- **Trigger when any holds:**
  - Changed path is an architecture/design doc — case-insensitive match on
    `docs/(specs|adr|arch|design|rfc)/`, or a filename containing
    `architecture`, `design`, `spec`, `rfc`, `adr`, `hld`, `lld`, or `tech-spec`.
  - Diff introduces infrastructure/topology change (new service, datastore,
    queue, cache, external dependency, IaC), trust-boundary/auth change, public
    API/contract change, or a migration that reshapes data ownership.
- **Invoke** (changed doc path when one changed, else the PR):

  ```
  Skill(wk-arch-review, args="<changed-doc-path | PR number>")
  ```

- Fold the result in: post a top-level self-review note linking the design
  rationale; add inline comments on the components arch-review flagged (SPOFs,
  unhappy paths, risky assumptions) so reviewers see them in context.
- Skip silently when no trigger matches.

## Step 2.5: Reconcile against existing self-review

Before presenting proposed comments, fetch every review thread on the PR
authored by the PR author (prior self-review). On a multi-round PR, the
"what's new since last push" framing makes it easy to restate rationale already
on the PR — each design decision should appear **exactly once**.

```bash
PR_NUM=$(gh pr view --json number --jq .number)
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
AUTHOR=$(gh pr view --json author --jq .author.login)
```

Use the canonical query from `skills/pr-resolve/references/graphql-review-threads.md`
with `-F o="$OWNER" -F r="$REPO" -F n="$PR_NUM"`, then filter by author + extract
fields:

```bash
# pipe the GraphQL result through jq
jq --arg a "$AUTHOR" '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.comments.nodes[0].author.login == $a)
  | {resolved: .isResolved, c: .comments.nodes[0]}
  | {path: .c.path, line: .c.line, resolved, body: .c.body}'
```

For each proposed new comment, check existing self-review threads for **topical
overlap** (same rationale, even on a different file/line). On overlap:

- **Drop** the new comment if the prior note already says everything it would, OR
- **Rewrite as a cross-reference** ("See related design note on
  `docs/specs/...:N`.") if the new location needs a pointer.

Resolve the prior thread only if its rationale is now **stale** — never just
because the new comment restates it.

**Approach-pivot thread audit.** New commits change a feature's logical approach
(the wk-workflow design-pivot trigger) → audit existing self-review threads
independently of any new proposed comment. A pivot leaves a thread that silently
contradicts the new code even when nothing new is being said about that path.

- Fetch unresolved self-review threads on the changed files.
- Flag any whose rationale describes the **old** approach (e.g., explaining
  serialization after a switch to parallel execution).
- Resolve each stale thread, repost updated rationale anchored to the new commit.
  Treat "approach changed, self-review not updated" exactly as a stale code
  comment.

Spec files are usually the canonical home for design rationale; implementation-
file notes should either add NEW context (tradeoff specific to this site) or
point at the spec.

## Step 2.6: Parallel-path completeness audit

Before posting, scan for sibling/parallel code paths that carry the same flaw as
anything this PR fixed or flagged. A bug class rarely lives in a single line —
credential redaction, input validation, error handling, retry logic, guards, and
cleanup-on-error recur across sibling paths.

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

- Sibling path needs the same fix → fold into **the same commit** (single-round
  review is the goal). List every path covered in the self-review comment.
- Path genuinely unaffected → note the audit was performed. Silence reads as "the
  agent didn't look."

## Step 2.7: Verify code-comment claims against current implementation

Before posting, scan the diff for **inline code comments and doc strings that
make behavioral claims** about the surrounding code; mentally execute each claim
against the implementation shipping in this PR. A comment is correct only if its
claim is true given what the code does today, not what it did when the comment
was written.

Behavioral claims to flag:

- "This makes X available" / "this enables Y"
- "Always works" / "is guaranteed to" / "never fails"
- "Required because" / "needed for" — the dependency must still hold
- Claims about subprocess, network, OS, or filesystem behavior depending on
  flags, depths, modes, or environment the implementation may have since narrowed
- Claims about what other code paths do (names a function/behavior elsewhere that
  may have changed)

For each flagged comment:

1. Read the surrounding implementation in current PR state.
2. Decide whether the claim is still true. Implementation narrowed (deeper fetch
   → shallower, recursive scan → flat, guarded path → unguarded) → comment is
   likely stale.
3. Stale → **fix the comment in this PR**, do not leave a review note about it.
   Stale comments are documentation bugs, not design notes. Fold the fix into the
   same commit that invalidated it if still possible, else add a comment-only fix
   commit on the same branch.
4. Claim still true but non-obvious → leave a self-review note pointing at the
   load-bearing detail so future readers know what holds the comment up.

Runs independently of Step 2.6's parallel-path scan: parallel-path looks for
sibling instances of a fix; comment-accuracy looks for stale narration of a
behavior. Both fire on the same trigger (implementation changed) but cover
different surfaces.

## Step 3: Present Comments

Show a numbered summary of proposed comments:

```
1. <module>/handler.ts:42 — Chose HMAC over RSA here because tokens are short-lived
2. <module>/store.ts:91 — This eviction strategy trades memory for latency
3. <module>/routes.ts:15 — Breaking change: removed deprecated v1 endpoint
```

**HARD RULE — never ask "want me to post this?".** Posting the pending (draft)
review is unconditional after the summary; GitHub's Submit button is the human
checkpoint, not a terminal prompt. The user opts out by saying "don't post" /
"wait" / "let me edit first" before the summary is presented. After the summary,
proceed directly to Step 4 — no confirmation round-trip.

## Step 3.5: Validate every comment line lies inside a diff hunk

**HARD RULE:** Before POSTing, verify each comment's `line` falls inside a `@@`
hunk range in `git diff <base>...HEAD -- <path>`. The API rejects out-of-hunk
lines with `422 "Line could not be resolved"`.

- Resolve `<base>` dynamically: `gh pr view --json baseRefName --jq .baseRefName`.
- Extract `+N,M` ranges from each `@@` header for the file; commentable set =
  union of `[N, N+M-1]` per hunk on the new-file side.
- For each proposed comment, check `line ∈ commentable_set`. If not:
  - Snap to the nearest in-hunk line, **or**
  - Convert to a file-level comment by omitting both `line` and `side` in the API
    payload.
- Absolute file line numbers from `Read` output are not commentable unless they
  also appear in a diff hunk — never assume the two are the same.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" -- "$PATH_TO_FILE" \
  | grep -E '^@@' | sed -E 's/.*\+([0-9]+),?([0-9]*).*/\1 \2/'
```

## Step 4: Post Comments

Post the pending review immediately after Step 3's summary — no approval prompt.
Create a PENDING review via GitHub API:

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

- Omit `event` → pending (draft) review. `"event": "PENDING"` is not a valid enum
  value and returns HTTP 422.
- Valid event values (`APPROVE`, `REQUEST_CHANGES`, `COMMENT`) are for
  *submitting* a review, not creating one.
- Set `commit_id` to the PR's HEAD SHA to anchor the review.
- Review stays **pending** (draft) until the user submits it on GitHub.

## Updating an Existing Self-Review

New commits pushed to a PR that already has self-review comments:

1. **Resolve stale comments** that no longer apply — use `gh api` to resolve
   review threads or delete outdated comments.
2. **HEAD rewritten since the review was staged? Delete and re-post the pending
   review.** A pending review's `commit_id` pins it to a HEAD SHA; ANY event that
   rewrites the pushed HEAD orphans the review and every inline comment (the
   comments endpoint returns empty, and GitHub does not migrate them) — a
   self-initiated force-push OR a host-initiated auto-rebase when the base branch
   merges and the child is retargeted onto new SHAs. Before treating a staged
   review as live, confirm its `commit_id` still equals the current HEAD
   (`gh pr view --json headRefOid`); on mismatch, run
   `DELETE /pulls/{n}/reviews/{id}`, then re-stage a fresh pending review
   anchored to the new HEAD SHA.
   - **`commit_id` is only one drift axis — check the comments too.** Anchors rot
     while a review is still nominally current, so compare each comment's
     `position` against its `original_position`. A mismatch on either axis means
     delete and re-stage.
   - A pending comment reports `line: null`, so `position`/`original_position`
     are the only usable drift signal — never gate comment staleness on `line`.
   - **Preserve every comment body before the DELETE.** Write them to a temp file
     with the **Write tool** first: the delete becomes safe, and the re-staged
     version can correct any bullet that went factually stale meanwhile.
3. **Add new comments** for any critical changes introduced by the new commits.
4. Present the updated comment set for approval before posting.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Invoked by `wk-pr` | Full self-review flow after CI passes |
| "self-review this PR" | Manual invocation on current PR |
| New commits pushed | Update existing comments, resolve stale ones |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn self-review`).
