# PR Resolve — Command Reference

Verbatim command blocks and the suggestion format, relocated from `SKILL.md`
to keep the skill body lean. Every command here is load-bearing; use exactly.

## Step 1 — Identify the PR

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,headRefOid
```

Co-author detection:

```bash
PR_AUTHOR=$(gh pr view --json author --jq '.author.login')
CURRENT_USER=$(gh api user --jq '.login')
```

## Step 2 — Sync branch

Reconcile the remote PR branch first (keeps next push fast-forward, avoids a
divergent second merge commit):

```bash
git fetch origin
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)

if [ -n "$(git log --oneline HEAD..origin/$HEAD_BRANCH 2>/dev/null)" ]; then
  git rebase "origin/$HEAD_BRANCH"
fi
```

Integrate the base branch — merge-aware pre-check (plain-merge when HEAD already
contains a base merge and `$BEHIND` is small):

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git fetch origin "$BASE"
BEHIND=$(git rev-list --count "HEAD..origin/$BASE")
LAST_BASE_MERGE=$(git log --merges --first-parent --pretty=format:%H \
  | while read sha; do
      if git merge-base --is-ancestor "$sha^2" "origin/$BASE" 2>/dev/null; then
        echo "$sha"; break
      fi
    done)
if [ -n "$LAST_BASE_MERGE" ] && [ "$BEHIND" -le 5 ]; then
  git merge "origin/$BASE" --no-edit
fi
```

Stage resolved files from the repo root (session cwd may be a subdirectory where
`git add <repo-relative-path>` exits 128; applies here and in Step 6):

```bash
git -C "$(git rev-parse --show-toplevel)" add <paths>
```

Base-advance conflict (upstream PR merged) — rebase onto the new base:

```bash
git fetch origin "$BASE_BRANCH"
git rebase --onto "origin/$BASE_BRANCH" "$(git merge-base HEAD "origin/$BASE_BRANCH")"
```

A clean local merge does not clear GitHub's `mergeable: CONFLICTING` when upstream
deleted a file the branch modified — GitHub recomputes from the original PR
ancestor, which still holds the file. `mergeable: CONFLICTING` after a merge →
pivot to the rebase above, never a second merge.

Stacked PR CLOSED with its base branch deleted (parent squash-merged under
`delete_branch_on_merge`) — recover in order; the head branch must still exist:

```bash
# 1. recreate the deleted base ref at the merge target's current tip
TARGET_SHA=$(gh api "repos/$OWNER/$REPO/git/refs/heads/$TRUNK" --jq .object.sha)
gh api -X POST "repos/$OWNER/$REPO/git/refs" -f ref="refs/heads/$DELETED_BASE" -f sha="$TARGET_SHA"
gh pr reopen "$NUMBER"                                          # 2. reopen (base now exists)
gh api -X PATCH "repos/$OWNER/$REPO/pulls/$NUMBER" -f base="$TRUNK"  # 3. retarget to trunk
gh api -X DELETE "repos/$OWNER/$REPO/git/refs/heads/$DELETED_BASE"   # 4. drop the temp branch
# 5. drop the parent's squash-duplicated commits so the diff is only the child's
git rebase --onto "$TRUNK" "$OLD_BASE_TIP" HEAD
```

## Step 3 — Fetch unresolved comments

**Pending review handling** (a pending review blocks reply posting with 422, and blocks `PATCH` edits to its own review comments with 404):

- Author's/current-user's own → never submit (Hard Rule 13); note once; resolve worked threads via the no-body GraphQL mutation (not gated by the pending review). For a substantive reply that cannot post inline, use a top-level `POST /issues/{n}/comments` noting the constraint; defer any edit to the author's own annotation until the pending review is submitted or dismissed. Note the deferral in the summary — pushed fixes stand on their own and bots re-scan on green CI.
- Another user's pending review → surface once, proceed without it.

Build the comment map (GraphQL for unresolved threads, REST for full details):

```bash
# Inline comments
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, node_id, path, line, original_line, position, body,
    user: .user.login, user_type: .user.type,
    author_association: .author_association, updated_at, in_reply_to_id}'

# Review summary bodies
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate \
  --jq '.[] | select(.body != null and .body != "") |
    {id, state, body, user: .user.login, user_type: .user.type, submitted_at}'

# PR conversation comments
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate \
  --jq '.[] | {id, node_id, body, user: .user.login,
    user_type: .user.type, author_association: .author_association,
    created_at, updated_at}'
```

**Three-surface pre-flight gate (HARD RULE).** Track per-invocation flags
(`inline_comments_fetched`, `review_bodies_fetched`, `issue_comments_fetched`);
cached results from a prior invocation do not count. Any flag false → stop and
report the failed surface; never advance on partial fetches.

Pre-check pending self-reviews (a pending review blocks reply posting with HTTP
422):

```bash
CURRENT_USER=$(gh api user --jq '.login')
PENDING_REVIEW_ID=$(gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  | jq --arg u "$CURRENT_USER" -r \
  '.[] | select(.state == "PENDING" and .user.login == $u) | .id')
```

Submit it as `COMMENT` before posting any reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/$PENDING_REVIEW_ID/events \
  --method POST -f event=COMMENT
```

## Step 4 — Suggestion format

Every suggestion includes reasoning for applying and discarding:

```
### Comment {n}/{total}: {path}:{line}
**Reviewer:** @{user} {bot_badge}
**Comment:** {body}
**Reply chain:** {summary of any replies, or "none"}
**Suggested fix:** {code change or snippet}
**Why this fix:** {problem solved and reviewer concern addressed}
**Why skip:** {false positive, already handled, out of scope, style, or "No valid reason to skip"}
```

`{bot_badge}` is `🤖 (bot)` for bots, omitted otherwise. Be honest in the skip
rationale; if no good skip reason exists, say so.

## Step 5 — Consultation prompts

Bulk-queue preview (obvious fixes; ask once before queueing):

```
**Bulk-queue candidates ({K} obvious fixes — skip rationale empty / no valid reason):**
1. {path}:{line} — {summary}  2. ...

Queuing all {K} for Step 6 (one commit per triage unit; replies/resolution
normal; runs only after all judgment-required items triaged). Reply **stop**
for per-comment consultation, or list indices to consult.
```

Per-comment prompt (one judgment-required comment at a time, after the §4
suggestion format):

```
**Comment {n}/{total}:** How would you like to handle this?
**(a)** Apply the suggested fix
**(e)** Edit the suggested fix (describe how to adjust it)
**(d)** Dismiss — not applicable / false positive (reuses the Step 4 `Why skip` rationale)
**(t)** Defer to ticket — track in a follow-up issue/ticket instead of fixing in-PR
**(s)** Skip — leave as-is without resolving
**(r)** Rethink — re-analyze this comment more thoroughly before deciding
{additional context-specific options using non-reserved letters}
```

Decision handling — record exactly one outcome per decision; `a`/`e`/`d`/`t` all
mark `resolve_after_push`:

- `a` Apply — record in `fixes_to_apply` `{path, line, description, code_change, threadId, commentId}`; draft "Fixed — {brief explanation}".
- `e` Edit — ask how to adjust; record the refinement in `fixes_to_apply`; draft the adjusted reply.
- `d` Dismiss — reuse the Step 4 `Why skip` rationale as the reason; do not re-ask. Ask only when it is empty / "No valid reason to skip", or to edit it. Draft "Dismissed — {reason}".
- `t` Defer — ask for the ticket URL/key; record in `deferrals` `{path, line, ticket_url, ticket_key, threadId, commentId}`; draft "Tracked in [{ticket_key}]({ticket_url}) — will address in a follow-up.".
- `s` Skip — record in `skipped`; leave the thread open and untouched.
- `r` Rethink — re-read the comment, surrounding code, and referenced context; produce deeper analysis with alternatives/risks; re-present the same comment with the same reserved options.

## Step 6 — Issue-class scan before each fix

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" | grep -nE '<class-pattern>' \
  | grep -v '<already-fixed-pattern>'
```

Per-class grep targets (a refactor clones the defect onto sibling lines):

- Credential/token leaks → grep shell commands and stderr redirections, minus already-redacted lines.
- Validation/exception/retry gaps → grep the affected symbol plus every entry/call site.
- Race/TOCTOU → grep the resource path plus every read-then-write site.
- Value/message/constant reporting → grep the **whole changed file** (not just the diff) for the same shape (`grep "timed out after %v" <file>`).

Probe the real config path when a fix targets a file named by user shorthand
(CI/pipeline step config often lives in a generator/template file, not the
named one):

```bash
grep -rn '<step-key>' <config-dir>
```

Isolate overlapping fixes without interactive staging: when two accepted fixes
land in the same file with interleaved lines, edit the *other* fix's lines
back out temporarily, `git add`/commit the file with only the current fix's
lines present, then re-apply the other fix's edit and repeat for its own
commit — avoids `git add -p`'s hunk-splitting fragility.

Commit (one commit per triage unit; omit the trailer in non-co-author sessions):

```bash
git add {files}
git commit -m "$(cat <<'EOF'
fix(scope): 🐛 {brief description}

Addresses review comment by @{reviewer} on {path}:{line}

Co-authored-by: {pr_author_name} <{pr_author_email}>
EOF
)"
```

Record the full SHA immediately, then build the clickable reply link (never infer
the full SHA from a short SHA):

```bash
FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)
```

```markdown
Fixed in [`<short>`](https://github.com/{owner}/{repo}/commit/{full_sha}) — {explanation}
```

## Step 8 — Push, divergence guard, replies, resolution

Post-rewrite divergence guard (only when this session rewrote history):

```bash
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)
git fetch origin "$HEAD_BRANCH" --quiet
COUNTS=$(git rev-list --left-right --count "HEAD...origin/$HEAD_BRANCH")
AHEAD=$(echo "$COUNTS" | cut -f1)
BEHIND=$(echo "$COUNTS" | cut -f2)
```

Push:

```bash
git push
```

Post replies, routed by surface:

```bash
# Inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"

# Review body or conversation comment
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --method POST -f body="{reply_text}"
```

Decision → reaction map (react on the original comment; failures are
fire-and-forget): `+1` for `a`/`e`/`t`; `-1` for `d`; `heart` for follow-ups;
none for `s`/`r`.

Resolve a thread via GraphQL:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_id}"
```

Reply routing & resolution rules:

- Before bot replies, refresh bot thread IDs: re-run the GraphQL `reviewThreads`
  query against post-push HEAD, match by `(path, line, root_comment.body_excerpt)`;
  skip replies for dropped findings.
- Resolve via `resolveReviewThread`; `NOT_FOUND` → refresh IDs once, match by
  stable identity, retry; no match / retry fails → log and continue.
- Inline-reply `404` (REST IDs unstable, see Step 3) → log and keep the thread in
  `resolve_after_push`.
- Fully outdated thread (`line: null`) → skip the REST reply (every REST op 404s,
  incl. GET); post one top-level `gh pr comment` summarizing fixes instead.
- Detect in-place bot summary updates by re-fetching each captured bot issue
  comment: active→clean = positive resolution; added findings = regression →
  re-enter Step 4.

## Step 9 — Check merge conflicts

```bash
git fetch origin
git merge --no-commit --no-ff origin/{base_branch} 2>&1
```

## Step 10 — Final summary template

```
## PR #{number} Review Resolution Complete

**Branch synced:** {status}
**Comments processed:** {total} of {total_found}
**Self-review excluded:** {count}
**Feedback in self-review threads:** {count}
**Bot reviews handled:** {count} ({applied} applied, {dismissed} dismissed)
**Reviewer fixes:** {count}
**Deferred to tickets:** {count}
**Commits pushed:** {count}
**Replies posted:** {count}
**Threads resolved:** {count}
**Threads left open:** {count}
**Merge conflicts:** {status}

PR URL: {url}
```
