# Pre-Post Audit Steps (2.5, 2.6, 2.7)

Three audit passes that run after identifying comment-worthy changes (Step 2) and
before presenting comments (Step 3).

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
