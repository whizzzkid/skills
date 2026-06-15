---
name: wk-pr-resolve
description: >-
  Address PR review comments interactively — resolve feedback from reviewers by
  implementing fixes, preparing response comments, and managing the full
  resolution cycle. Use when asked to resolve PR comments, address review
  feedback, fix PR issues, respond to reviewers, or handle PR conversations.
  Also auto-activate on indirect references — "fix the comment", "there's a
  description/comment issue", "address the feedback", "fix this on the PR" —
  whenever an open PR exists on the current branch. Prefer activating over
  asking a clarifying question; the open PR is the implied target.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh api repos/*)"
  - "Bash(gh api issues/*)"
  - "Bash(gh api user:*)"
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
  - "Bash(git merge-base:*)"
  - "Bash(git rev-list:*)"
  - "Bash(git cherry-pick:*)"
  - "Bash(git show:*)"
  - "Bash(jq:*)"
  - "Bash(npm:*)"
  - "Bash(make:*)"
  - "Bash(cargo:*)"
  - "Bash(ruby:*)"
  - "Bash(bundle:*)"
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - ToolSearch
  - AskUserQuestion
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.06.15-191526'
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
and manage the full resolution cycle from sync to summary.

## Hard Rules

0. **Scope/render GitHub payloads through `wk-gh`.** Satisfy `wk-gh` org-scope
   gates before any GitHub read/write. When a direct `gh api` call is the only
   transport, append the canonical outbound footer at payload-render time to
   every reply, PR body edit, and thread message.
1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
   - **HARD RULE — route every outbound reply/dismissal body through
     `Skill(wk-tone)` before drafting or posting.** They are prose posted as the
     user; filter banned register before payload render.
3. **Only resolve threads you actually worked on** — after a fix, explicit
   dismissal, or tracked deferral. Never resolve follow-up questions, skipped,
   rethink-pending, or ordinary self-review threads.
4. **Never force-push.** Use regular `git push` only.
5. **Never commit without attempting verification.** If verification is
   unavailable or fails, inform the user before proceeding.
6. **Commits follow `wk-commit` conventions** — conventional format with emoji,
   signed commits, HEREDOC messages. Never use `--no-gpg-sign`.
7. **One commit per triage unit** (the final Step 4 suggestion after merge/split
   decisions). Do not bundle separate reviewer comments unless Step 4 merged
   them. Push once after all commits exist.
8. **Exclude self-review comments.** Do not triage, reply to, fix, or resolve
   threads whose root comment was authored by the PR author or current user.
   - **Resolve submitted self-review threads only at merge readiness** — branch
     protection can count every unresolved thread regardless of authorship.
   - **Surface external replies inside self-review threads** in the summary; do
     not triage or resolve them.
   - **User-touched reviewer threads allow one narrow follow-up** — on a
     reviewer/bot thread where the user already replied, post one follow-up only
     when the session changed the finding or a new item needs callout. Still
     requires Hard Rule 2 confirmation.
9. **Co-author attribution.** When the current user is not the PR author, add a
   `Co-authored-by:` trailer for the PR author on every commit. Real identities
   only; never invent agent co-authors.
10. **Include bot reviews** as first-class feedback. Evaluate each for
    correctness before accepting or dismissing.
11. **Adversarial-review gate before push.** New commits this session must pass
    `wk-adversarial-review` before `git push`. Blocked verdict ⇒ no push; fix and
    re-invoke until clear.
12. **Implement handoff documents before deleting them.** When the branch holds
    a file whose name signals remaining work, read it fully and implement its
    items before removing it; delete it in the same commit as the last
    implementation change. Present a plan first if the work is large or spans
    repos.

## Step 1: Identify the PR

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,headRefOid
```

If no PR is detected, ask for a number or URL. Extract `{owner}`, `{repo}`,
`{number}`, `{base_branch}`, `{head_sha}`.

### Detect co-author scenario

```bash
PR_AUTHOR=$(gh pr view --json author --jq '.author.login')
CURRENT_USER=$(gh api user --jq '.login')
```

`$PR_AUTHOR != $CURRENT_USER` → co-author session: record both logins, treat both
as self for comment exclusion, give the PR author `Co-authored-by:` on every
commit.

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

Co-author session adds:
> "Note: PR authored by @{pr_author}. Commits will include co-author attribution.
> Comments from both you and @{pr_author} are excluded from triage."

## Step 2: Sync Branch

Sync with both the base and remote PR branch before triaging.

### Reconcile the remote PR branch first

```bash
git fetch origin
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)

if [ -n "$(git log --oneline HEAD..origin/$HEAD_BRANCH 2>/dev/null)" ]; then
  git rebase "origin/$HEAD_BRANCH"
fi
```

Keeps the next push fast-forward and avoids a divergent second merge commit.

### Integrate the base branch

Merge-aware pre-check: when HEAD already contains a base merge and `$BEHIND` is
small, plain-merge.

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
  git merge "origin/$BASE"
fi
```

Otherwise delegate base integration to `wk-pr-update` only if it preserves the
no-force-push contract. If `wk-pr-update` reports an unresolvable conflict, a
validation regression, or a required forced push, stop and surface the blocker.

## Step 3: Fetch Unresolved Comments

Fetch all three feedback surfaces every run:

| Surface | Endpoint | What it holds |
|---|---|---|
| Inline review comments | `/pulls/{n}/comments` | Line-attached feedback |
| Review summary bodies | `/pulls/{n}/reviews` | Overall review text |
| PR conversation comments | `/issues/{n}/comments` | Top-of-PR discussion, bot summaries |

### Three-surface pre-flight check

Track per-invocation flags (`inline_comments_fetched`, `review_bodies_fetched`,
`issue_comments_fetched`); cached results from a prior invocation do not count.
If any flag stays false, stop and report which surface failed. Never advance
with partial fetches.

### Agent-observed drift is first-class feedback

If PR metadata, diff, or docs drift appears during Steps 1–3, inject it into the
comment map as `surface: agent_observation` with a `bot_badge` flag and run it
through triage like any other finding.

### Build the comment map

Use GraphQL for unresolved threads and REST for full details. The map includes
`threadId`, `commentId`, `path`, `line`, `body`, `user`, `userType`,
`replies[]`, `isOutdated`, `isResolved`.

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

### Classify comment authors

| `user_type` | Pattern | Classification |
|---|---|---|
| `Bot` | Any bot suffix or custom bot login | Bot review |
| `User` | Matches PR author login | Self-review |
| `User` | Matches current user login in co-author session | Self-review |
| `User` | Any other login | Reviewer |

### Pre-check pending self-reviews

A pending review blocks reply posting with HTTP 422.

```bash
CURRENT_USER=$(gh api user --jq '.login')
PENDING_REVIEW_ID=$(gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  | jq --arg u "$CURRENT_USER" -r \
  '.[] | select(.state == "PENDING" and .user.login == $u) | .id')
```

If one exists, ask the user to submit it as `COMMENT` or abort, then submit
before posting any reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/$PENDING_REVIEW_ID/events \
  --method POST -f event=COMMENT
```

### Filter and group

- Active = thread unresolved, not self-review, not truly outdated.
- Outdated thread, concern gone → record auto-skipped and resolve it. Unresolved outdated thread → still open feedback.
- Sort active comments by file path then line; separate bot from human in the summary.
- Report skipped self-review threads and external replies hidden inside them.

## Step 4: Generate Suggestions

### Bot and non-convergence handling

- Track bot thrash by `(path_prefix, concern_class)` and total active findings per round.
- Stop and ask before another fix when: same pair re-fires 3×; totals stop falling for 2 consecutive rounds; or a new finding contradicts an accepted fix.
- Evaluate bot suggestions; never accept blindly.
- Bot reply: documented command syntax if available, else a generic reply tagging the bot and stating the decision.

### All-Minor bulk-dismiss gate

If every active finding is Minor and each has a plausible skip rationale, offer
one bulk action before per-item triage:

> "All {N} findings are Minor. Bulk dismiss all, or triage individually?
> (a) dismiss all  (b) triage individually"

Enter per-item triage only when ≥1 finding is Major/Critical or any finding
lacks a plausible skip rationale.

### Order of processing

**HARD RULE — triage every comment before applying any fix.** Classify the whole
set first, then apply accepted fixes as one batched pass. Do not loop
comment-by-comment through fix/commit/push.

- Process bot reviews first, then human comments.
- For each: read full file context, the comment, and the reply chain before generating a concrete fix.

### Org-specific policy questions

When a reviewer question touches org-specific policy, search the configured KB
first and cite an authoritative doc; fall back to general knowledge only if the
KB returns nothing, flagging the fallback in the reply. Skip for code-level
intent, design rationale, or test-coverage questions.

### Missing-documentation findings

Before surfacing a bot finding that claims behavior/rationale/trade-off is
undocumented, grep the diff, touched files, and repo docs. If docs cover it or
code makes the rationale unambiguous, include the reference and dismiss.
Otherwise present normally.

### Suggestion format

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

### Detect design flaws

Before drafting a localized patch, decide whether the comment signals a design
flaw. Triggers: "this might not trigger", "this depends on X", "what happens if
{edge case}", "why do we need this at all", "this is duplicated with", "the
contract is unclear". When fired, present the design change first and a
clarifying reply second; in Step 5 `(a)` applies the design option unless edited.

### Classify suggestions

Tag each `obvious-fix` or `judgment-required`:

| Tag | Condition |
|---|---|
| `obvious-fix` | Skip rationale is empty, "no valid reason", "no good reason to skip", `—`, or otherwise concedes the comment is right. |
| `judgment-required` | A real tradeoff, false-positive possibility, scope question, multiple valid approaches, or security/performance judgment exists. |

Default to `judgment-required` when uncertain. Immediately before any Step 5
consultation prompt, re-read the skip rationale; if it concedes the comment is
right, re-tag `obvious-fix` and route to bulk-apply. Severity does not bypass
this.

### Merge, split, and convergence

- Merge duplicate comments on the same `path:line` with the same concern.
- Split one comment with multiple distinct sub-items into one suggestion each.
- Treat multi-reviewer convergence on the same concern class as an incomplete
  prior fix: merge the class, scan the full PR diff for sibling instances, fix
  the class, and reply from each flagging thread.

## Step 5: Consult — Collect All Decisions First

**HARD RULE:** Consultation-only. Do not read files for editing, write code,
commit, push, or post replies.

### Partition before any prompts

Place every suggestion into exactly one list: `obvious_fixes[]` (tag ==
`obvious-fix`) or `judgment_required[]`. Re-read each skip rationale during
partition; re-route any item whose rationale concedes the comment is right into
`obvious_fixes[]`.

### Bulk-queue preview for obvious fixes

If obvious-fix items exist, present one preview and ask once before queueing:

> "**Bulk-queue candidates ({K} obvious fixes — skip rationale empty / no valid reason):**
>
> 1. {path}:{line} — {one-line summary}
> 2. ...
>
> I'll queue all {K} for Step 6 (one commit per triage unit; replies/resolution
> normal). Step 6 runs only after all judgment-required items are triaged. Reply
> **stop** for per-comment consultation, or list indices to consult."

Default (silence/affirmative/unrelated): queue all obvious-fix items into
`fixes_to_apply` and proceed. Only explicit `stop` or `consult <indices>` diverts.

### Present one judgment-required comment at a time

For each, present the full suggestion format and ask:

> **Comment {n}/{total}:** How would you like to handle this?
> **(a)** Apply the suggested fix
> **(e)** Edit the suggested fix (describe how to adjust it)
> **(d)** Dismiss — not applicable / false positive (reuses the Step 4 `Why skip` rationale)
> **(t)** Defer to ticket — track in a follow-up issue/ticket instead of fixing in-PR
> **(s)** Skip — leave as-is without resolving
> **(r)** Rethink — re-analyze this comment more thoroughly before deciding
> {additional context-specific options using non-reserved letters}

`a`, `e`, `d`, `t`, `s`, `r` are reserved; extra options use other letters and
must not redefine them. Wait for the response before the next comment. Never
batch two consultation prompts in one message.

### Decision handling

Record exactly one outcome per decision:

- `a` Apply — record in `fixes_to_apply` `{path, line, description, code_change, threadId, commentId}`; draft "Fixed — {brief explanation}"; mark `resolve_after_push`.
- `e` Edit — ask how to adjust; record the refinement in `fixes_to_apply`; draft the adjusted reply; mark `resolve_after_push`.
- `d` Dismiss
  - Reuse the `Why skip` rationale already presented for this comment in Step 4 as the dismissal reason; do not re-ask why.
  - Ask the user only when that rationale is empty / "No valid reason to skip", or to edit it.
  - Draft "Dismissed — {reason}"; mark `resolve_after_push`.
- `t` Defer — ask for the ticket URL/key; record in `deferrals` `{path, line, ticket_url, ticket_key, threadId, commentId}`; draft "Tracked in [{ticket_key}]({ticket_url}) — will address in a follow-up."; mark `resolve_after_push`.
- `s` Skip — record in `skipped`; leave the thread open and untouched.
- `r` Rethink — re-read the comment, surrounding code, and referenced context; produce deeper analysis with alternatives/risks; re-present the same comment with the same reserved options.

### After all decisions collected

> "All {total} comments reviewed. Decisions collected:
> - {obvious_count} obvious fixes queued
> - {apply_count} judgment-required fixes accepted
> - {followup_count} follow-up questions to post
> - {dismiss_count} dismissals
> - {defer_count} deferrals
> - {skip_count} skipped
>
> Moving to implementation — I'll apply all accepted fixes now, one commit per
> triage unit, verifying each."

## Step 6: Execute — Apply Fixes, Verify, and Commit

Apply all Step 5 decisions: process `fixes_to_apply`, `dismissals`, `deferrals`
in order.

### Issue-class scan before each fix

Identify the issue class; grep the full PR diff for sibling paths sharing it.
Include siblings in the same commit only when they share the triage unit or were
merged by Step 4.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" | grep -nE '<class-pattern>' \
  | grep -v '<already-fixed-pattern>'
```

- Credential/token leaks: grep shell commands and stderr redirections, then subtract already-redacted lines.
- Validation/exception/retry gaps: grep the affected symbol plus every entry/call site.
- Race/TOCTOU: grep the resource path plus every read-then-write site.

### For each fix

1. Apply the change with Edit.
2. Verify with the repo's build/lint/test command. If no build system, warn
   once. If verification fails, ask whether to fix, commit anyway, or skip.
3. Commit one commit per triage unit:

   ```bash
   git add {files}
   git commit -m "$(cat <<'EOF'
   fix(scope): 🐛 {brief description}

   Addresses review comment by @{reviewer} on {path}:{line}

   Co-authored-by: {pr_author_name} <{pr_author_email}>
   EOF
   )"
   ```

   In non-co-author sessions, omit the PR-author trailer. `Co-authored-by` only
   for real contributors.
4. Record the full SHA immediately: `FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)`.
5. Update the drafted reply with a clickable commit link, deriving the full SHA
   from git (never infer from a short SHA):

   ```markdown
   Fixed in [`<short>`](https://github.com/{owner}/{repo}/commit/{full_sha}) — {explanation}
   ```

### For each dismissal or deferral

No code change — use the Step 5 reply. Deferrals reference the user-provided
ticket; never create tickets here.

**Do NOT push after each commit.** Push all commits together in Step 8.

## Step 7: Confirm Everything

### Skip redundant confirmation when decisions are explicit

Step 5 decisions (`a`, `e`, `d`, `t`, `s`) are explicit confirmation — do not
re-ask "proceed?" after a fully decided Step 5. The gate fires only when:

- an `(e)` edit was not echoed back verbatim;
- a co-author session inferred the PR author's name/email instead of reading it from git log / PR metadata; or
- an ambiguous batch slipped into Step 5.

When it fires:

> "Does this look correct? I will push {N} commits, post {M} threaded replies to
> individual review comments, resolve {R} threads, and leave {L} threads open for
> follow-up. Proceed? (yes / edit / abort)"

Be explicit that this skill posts threaded replies, not a formal PR Review.

### Resolution rule

Per Hard Rule 3: resolve only threads in `resolve_after_push`. Submitted
self-review threads resolve only at merge readiness.

### Disambiguate "review" objections

If the user says "don't post the self-review", "skip the review", or similar,
ask whether they mean a formal PR Review submission or the threaded replies.
Default to the former unless they confirm the latter.

## Step 8: Push and Respond

### Adversarial-review gate

Run `wk-adversarial-review` against the new commits before `git push`. Push is
conditional on a `clear` verdict or accepted `suggestions-only` A/B/C choice. On
`blocked`, address each blocker with a fresh atomic commit, re-invoke, loop until
clear.

### Post-rewrite divergence guard

If this session rewrote history, re-check divergence before pushing:

```bash
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)
git fetch origin "$HEAD_BRANCH" --quiet
COUNTS=$(git rev-list --left-right --count "HEAD...origin/$HEAD_BRANCH")
AHEAD=$(echo "$COUNTS" | cut -f1)
BEHIND=$(echo "$COUNTS" | cut -f2)
```

- `BEHIND == 0` → push is safe.
- `AHEAD > 0` and `BEHIND > 0` → cherry-pick remote-only commits onto the
  rewritten local tip, then re-check.
- If cherry-pick conflicts or remote-only commits are rewritten duplicates, stop
  and surface to the user.

### Push

```bash
git push
```

If rejected as non-fast-forward, re-run reconciliation when no history was
rewritten; if history was rewritten, use the divergence guard's cherry-pick
recovery instead of rebasing. Never force-push.

### Sync PR description immediately after push

**HARD RULE:** After every push, update the PR body before posting replies or
resolving threads — even when it looks current.

- Preserve metadata lines.
- Verify commit links, test-plan checkboxes, CI status, remaining work, known limitations, and file lists before deciding no drift.
- No drift → log an explicit "no drift detected" line naming the compared fields.

### Re-check self-review and docs drift

On every push:

- Re-read agent-posted self-review comments; if a fix changed the code a comment describes, correct or resolve it.
- Invoke `wk-docs` against files touched this session; update docs/specs/README when behavior, signatures, or config changed.

### Post replies, reactions, and resolve threads

Re-run the pending self-review check before the first reply; submit any pending
review as `COMMENT` first. Post replies sequentially, routed by surface:

```bash
# Inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"

# Review body or conversation comment
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --method POST -f body="{reply_text}"
```

- Prefix issue-comment replies with a quote of the original comment.
- React on the original: `+1` for `a`/`e`/`t`; `-1` for `d`; `heart` for follow-up questions; none for `s`/`r`. Reaction failures are fire-and-forget.
- Inline reply HTTP 404 → log, keep the thread in `resolve_after_push`. REST comment IDs die on force-push/bot replacement; GraphQL thread IDs are stable → resolve via GraphQL. GraphQL also fails → drop and continue.
- Before bot replies, refresh bot thread IDs: re-run the GraphQL reviewThreads query against post-push HEAD, match by `(path, line, root_comment.body_excerpt)`; skip replies for dropped findings.

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_id}"
```

- `NOT_FOUND` → refresh IDs once, match by stable identity, retry; no match/retry fails → log and continue.
- Detect in-place bot summary updates by re-fetching each captured bot issue comment: active→clean = positive resolution; added findings = regression → re-enter Step 4.
- Post-push comments matching `(path, line, concern)` from this session are already-addressed echoes: reply with the commit link, resolve, do not re-prompt or re-commit.

## Step 9: Check Merge Conflicts

```bash
git fetch origin
git merge --no-commit --no-ff origin/{base_branch} 2>&1
```

If clean, abort the test merge and report success. If conflicts are detected,
abort and ask whether to resolve them now.

## Step 9.4: Capture Adversarial-Review Learnings

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class surfaced
before entering the CI wait. Do not skip for short or routine sessions. If zero
findings were active, emit one baseline-holding learning.

Classify processed comments into generic issue classes (security, validation,
exception handling, race/TOCTOU, retry/timeout, defensive/dead guard,
API/external-call shape, docs/rationale drift, comment-accuracy drift, or a new
class). For each non-empty class invoke `Skill(wk-learn, args="adversarial-review")`,
encoding class, mechanism, detection sketch, and confidence — generic patterns
only; no file paths, line numbers, reviewer logins, or SHAs. Re-run for any new
batch the post-CI loop surfaces before the next CI wait.

## Step 9.5: Wait for CI, Then Loop on New Comments

- Delegate CI polling to the configured CI skill; wait for `passed`, `failed`, or `canceled`.
- Failed/canceled → surface the failure and exit; fixing CI outranks further feedback.
- CI passes → re-run Step 3 against post-push HEAD; matching `(path, line, concern)` comments are already-addressed echoes.
- Genuinely new unresolved comments → loop: Step 4 (new findings) → Step 5 (same partition/one-at-a-time) → Steps 6–9 → Step 9.5 after the second push.
- Exit only when CI passes and the post-CI fetch surfaces no genuinely unresolved comments. Cap at 3 iterations; beyond that, surface the review-thrash loop to the user.

## Step 10: Final Summary

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

## Step 11: Session Retro

Invoke `wk-retro` to capture session-level learnings. Mandatory on every
completion, including narrow directives. Adversarial-review learnings were
emitted in Step 9.4.

## Quick Reference

| Trigger | Behavior |
|---|---|
| "resolve PR comments" | Full workflow |
| "address review feedback" | Full workflow |
| "fix the comment" / "there's a description issue" with an open PR | Auto-activate on the open PR |
| "fix PR #{number}" | Full workflow for the specified PR |
| "respond to reviewers" | Full workflow with focus on replies |
| Session ends | Emit adversarial-review learnings, then run `wk-retro` |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for verification commands
- Commit signing configured

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument:

```
wk-learn pr-resolve
```
