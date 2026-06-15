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
  version: '2026.06.15-092804'
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
and manage the full resolution cycle from sync to summary.

## Hard Rules

0. **Scope and render GitHub payloads through `wk-gh`.** Satisfy `wk-gh`
   org-scope gates before any GitHub read/write. When a direct `gh api`
   call is the only practical transport, append the canonical outbound footer
   at payload-render time for every reply, PR body edit, and thread message.
1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
   - **HARD RULE — route every outbound reply body through `Skill(wk-tone)`
     before drafting or posting.** Reply and dismissal bodies are prose posted
     as the user; banned register must be filtered before payload render.
3. **Only resolve threads you actually worked on.** A thread is resolvable
   only after a fix, explicit dismissal, or tracked deferral. Never resolve
   follow-up questions, skipped threads, rethink-pending items, or ordinary
   self-review threads.
4. **Never force-push.** Use regular `git push` only.
5. **Never commit without attempting verification.** If verification is
   unavailable or fails, inform the user before proceeding.
6. **Commits follow `wk-commit` conventions.** Use conventional format with
   emoji, signed commits, and HEREDOC messages. Never use `--no-gpg-sign`.
7. **One commit per triage unit.** The triage unit is the final Step 4
   suggestion after merge/split decisions. Do not bundle separate reviewer
   comments unless Step 4 explicitly merged them into one finding. Push once
   after all commits exist.
8. **Exclude self-review comments.** Do not triage, reply to, suggest fixes
   for, or resolve threads whose root comment was authored by the PR author
   or the current user.
   - **Resolve submitted self-review threads only at merge readiness.** Branch
     protection can count every unresolved thread regardless of authorship.
   - **Surface external replies inside self-review threads.** Report them in
     the summary, but do not triage or resolve them.
   - **User-touched reviewer threads allow one narrow follow-up.** On a
     reviewer or bot thread where the current user already replied, post one
     follow-up only when the session changed the finding or a new item needs
     explicit callout. Still require Hard Rule 2 confirmation.
9. **Co-author attribution.** When the current user is not the PR author,
   include a `Co-authored-by:` trailer for the PR author in every commit.
   Use real contributor identity only; do not invent agent co-authors.
10. **Include bot reviews.** Treat bot comments as first-class review
    feedback. Evaluate each for correctness before accepting or dismissing.
11. **Adversarial-review gate before push.** Any new commits produced in this
    session must pass `wk-adversarial-review` before `git push`. A blocked
    verdict means no push; fix and re-invoke until clear.
12. **Implement handoff documents before deleting them.** When the branch
    contains a file whose name signals remaining work, read it fully and
    implement its items before removing it. Delete it only in the same commit
    as the last implementation change. Present a plan first if the remaining
    work is large or spans repos.

## Step 1: Identify the PR

Determine the PR under review:

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,headRefOid
```

If no PR is detected, ask the user for a PR number or URL. Extract
`{owner}`, `{repo}`, `{number}`, `{base_branch}`, and `{head_sha}`.

### Detect co-author scenario

```bash
PR_AUTHOR=$(gh pr view --json author --jq '.author.login')
CURRENT_USER=$(gh api user --jq '.login')
```

If `$PR_AUTHOR != $CURRENT_USER`, this is a co-author session. Record both
logins. Both are treated as self for comment exclusion, and the PR author gets
`Co-authored-by:` attribution on every commit.

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

If co-author session:
> "Note: PR authored by @{pr_author}. Commits will include co-author
> attribution. Comments from both you and @{pr_author} are excluded
> from triage."

## Step 2: Sync Branch

Ensure the local branch is up to date with both the base branch and the remote
PR branch before fetching or triaging feedback.

### Reconcile the remote PR branch first

```bash
git fetch origin
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)

if [ -n "$(git log --oneline HEAD..origin/$HEAD_BRANCH 2>/dev/null)" ]; then
  git rebase "origin/$HEAD_BRANCH"
fi
```

Keep the next push fast-forward and avoid creating a second merge commit that
diverges from the remote.

### Integrate the base branch

Run a merge-aware pre-check before delegating. When HEAD already contains a
merge commit from the base and `$BEHIND` is small, use a plain merge:

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

For all other cases, delegate base-branch integration to `wk-pr-update` only
if it preserves the no-force-push contract. If `wk-pr-update` reports an
unresolvable conflict, a validation regression, or a required forced push, stop
the resolve flow and surface the blocker to the user.

## Step 3: Fetch Unresolved Comments

Fetch all three GitHub feedback surfaces every run:

| Surface | Endpoint | What it holds |
|---|---|---|
| Inline review comments | `/pulls/{n}/comments` | Line-attached feedback |
| Review summary bodies | `/pulls/{n}/reviews` | Overall review text |
| PR conversation comments | `/issues/{n}/comments` | Top-of-PR discussion and bot summaries |

### Three-surface pre-flight check

Track explicit per-invocation flags:

```
inline_comments_fetched  = false
review_bodies_fetched    = false
issue_comments_fetched   = false
```

Cached results from a prior invocation do not count. If any flag remains false,
stop and report which surface failed. Never silently advance with partial
fetches.

### Agent-observed drift is first-class feedback

If PR metadata, diff, or docs drift appears during Steps 1–3, inject it into
the comment map as `surface: agent_observation` with a `bot_badge` flag. Treat
it like any other finding through triage, consultation, and fix/defer/dismiss.

### Build the comment map

Use GraphQL to fetch unresolved review threads and REST to fetch full comment
details. The map must include `threadId`, `commentId`, `path`, `line`, `body`,
`user`, `userType`, `replies[]`, `isOutdated`, and `isResolved`.

Fetch inline comments:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, node_id, path, line, original_line, position, body,
    user: .user.login, user_type: .user.type,
    author_association: .author_association, updated_at, in_reply_to_id}'
```

Fetch review summary bodies:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate \
  --jq '.[] | select(.body != null and .body != "") |
    {id, state, body, user: .user.login, user_type: .user.type, submitted_at}'
```

Fetch PR conversation comments:

```bash
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

Before processing comments, check whether the current user has a pending
review. A pending review blocks reply posting with HTTP 422.

```bash
CURRENT_USER=$(gh api user --jq '.login')
PENDING_REVIEW_ID=$(gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  | jq --arg u "$CURRENT_USER" -r \
  '.[] | select(.state == "PENDING" and .user.login == $u) | .id')
```

If a pending review exists, ask the user to submit it as `COMMENT` or abort.
Submit it before posting any reply:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/$PENDING_REVIEW_ID/events \
  --method POST -f event=COMMENT
```

### Filter active comments

A comment is active when the thread is unresolved, not self-review, and not
truly outdated. If an outdated thread's concern is gone, record it as
auto-skipped and resolve it; an unresolved outdated thread still counts as open
feedback.

### Group by file

Sort active comments by file path, then line number. Separate bot comments from
human reviewer comments in the summary. Report skipped self-review threads and
external replies hidden inside self-review threads.

## Step 4: Generate Suggestions

### Bot and non-convergence handling

Track bot re-review thrash by `(path_prefix, concern_class)` and by total
active findings per round.

- Stop and ask before another fix after three re-fires of the same pair.
- Stop and ask when totals stop falling for two consecutive rounds.
- Stop and ask when a new finding contradicts a previously accepted fix.
- Evaluate bot suggestions; never accept them blindly.
- Use documented bot command syntax when available; otherwise use a generic
  reply that tags the bot and states the decision.

### All-Minor bulk-dismiss gate

Before per-item triage, check severities. If every active finding is Minor and
each has a plausible skip rationale, offer one bulk action:

> "All {N} findings are Minor. Bulk dismiss all, or triage individually?
> (a) dismiss all  (b) triage individually"

Enter per-item triage only when at least one finding is Major/Critical or any
finding lacks a plausible skip rationale.

### Order of processing

**HARD RULE — triage every comment before applying any fix.** Classify the
entire comment set first, then apply accepted fixes as one batched pass. Do not
loop comment-by-comment through fix, commit, push, and next.

Process bot reviews first, then human reviewer comments. For each active
comment, read the full file context, reviewer comment, and reply chain before
generating a concrete suggested fix.

### Org-specific policy questions

When a reviewer question touches org-specific policy, search the configured
knowledge base before drafting the reply. Cite an authoritative doc when found.
Fall back to general knowledge only if the KB returns nothing relevant, and
flag that fallback in the reply. Skip this step for code-level intent, design
rationale, or test-coverage questions.

### Missing-documentation findings

Before surfacing a bot finding that claims behavior, design rationale, or a
trade-off is undocumented, grep the diff, touched files, and repo docs for the
claim. If existing docs cover it, include the reference and default to
dismiss-with-reference. If code makes the rationale unambiguous, note the
reference and dismiss. Otherwise present the finding normally.

### Suggestion format

Every suggestion must include reasoning for applying and discarding:

```
### Comment {n}/{total}: {path}:{line}
**Reviewer:** @{user} {bot_badge}
**Comment:** {body}
**Reply chain:** {summary of any replies, or "none"}
**Suggested fix:** {code change or snippet}
**Why this fix:** {problem solved and reviewer concern addressed}
**Why skip:** {false positive, already handled, out of scope, style, or "No valid reason to skip"}
```

Where `{bot_badge}` is `🤖 (bot)` if the commenter is a bot, omitted otherwise.
Be honest in the skip rationale. If no good skip reason exists, say so.

### Detect design flaws

Before drafting a localized patch, decide whether the comment signals a design
flaw. Trigger phrases include "this might not trigger", "this depends on X",
"what happens if {edge case}", "why do we need this at all", "this is
duplicated with", and "the contract here is unclear".

When the trigger fires, present the design change first and a clarifying reply
second. In Step 5, option `(a)` applies the design option unless the user edits.

### Classify suggestions

Tag each suggestion as `obvious-fix` or `judgment-required`.

| Tag | Condition |
|---|---|
| `obvious-fix` | The skip rationale is empty, "no valid reason", "no good
  reason to skip", `—`, or otherwise concedes the comment is right. |
| `judgment-required` | A real tradeoff, false-positive possibility, scope
  question, multiple valid approaches, or security/performance judgment exists. |

Default to `judgment-required` when uncertain. Immediately before any Step 5
consultation prompt, re-read the skip rationale. If it concedes the comment is
right, re-tag as `obvious-fix` and route to bulk-apply. Severity does not bypass
this rule.

### Merge, split, and convergence

- Merge duplicate comments targeting the same `path:line` with the same concern.
- Split one comment with multiple distinct sub-items into one suggestion per
  sub-item.
- Treat multi-reviewer convergence on the same concern class as an incomplete
  prior fix. Merge the class, scan the full PR diff for sibling instances, fix
  the class, and reply from each flagging thread.

## Step 5: Consult — Collect All Decisions First

**HARD RULE:** This step is consultation-only. Do not read files for editing,
write code, commit, push, or post replies.

### Partition before any prompts

Before emitting any Step 5 output, place every suggestion into exactly one
list:

```
obvious_fixes[]       # tag == "obvious-fix"
judgment_required[]   # tag == "judgment-required"
```

Re-read each skip rationale during partition. Re-route any item whose rationale
concedes the comment is right into `obvious_fixes[]`.

### Bulk-queue preview for obvious fixes

If obvious-fix items exist, present one preview and ask once before queueing:

> "**Bulk-queue candidates ({K} obvious fixes — skip rationale empty / no valid reason):**
>
> 1. {path}:{line} — {one-line summary}
> 2. ...
>
> I'll queue all {K} for Step 6 execution (one commit per triage unit; replies
> and thread resolution remain normal). Step 6 runs only after all
> judgment-required items below are triaged. Reply **stop** to switch any of
> these to per-comment consultation, or list the indices you want consulted."

Default on silence, affirmative, or unrelated reply: queue all obvious-fix
items into `fixes_to_apply` and proceed to judgment-required consultation. Only
explicit `stop` or `consult <indices>` diverts items.

### Present one judgment-required comment at a time

For each judgment-required suggestion, present the full suggestion format and
ask:

> **Comment {n}/{total}:** How would you like to handle this?
> **(a)** Apply the suggested fix
> **(e)** Edit the suggested fix (describe how to adjust it)
> **(d)** Dismiss — not applicable / false positive (explain why)
> **(t)** Defer to ticket — track in a follow-up issue/ticket instead of fixing in-PR
> **(s)** Skip — leave as-is without resolving
> **(r)** Rethink — re-analyze this comment more thoroughly before deciding
> {additional context-specific options using non-reserved letters}

The letters `a`, `e`, `d`, `t`, `s`, and `r` are reserved. Extra options must
use letters outside that set and must not redefine reserved letters.

Wait for the user's response before presenting the next comment. Never batch
two or more consultation prompts in one message.

### Decision handling

For each reserved decision, record exactly one outcome:

- `a` Apply
  - Record in `fixes_to_apply`: `{path, line, description, code_change, threadId, commentId}`.
  - Draft "Fixed — {brief explanation}".
  - Mark `resolve_after_push`.
- `e` Edit
  - Ask how to adjust the fix.
  - Record the refinement in `fixes_to_apply`.
  - Draft the adjusted reply.
  - Mark `resolve_after_push`.
- `d` Dismiss
  - Ask why.
  - Record the dismissal reason.
  - Draft "Dismissed — {reason}".
  - Mark `resolve_after_push`.
- `t` Defer
  - Ask for the ticket URL or key.
  - Record in `deferrals`: `{path, line, ticket_url, ticket_key, threadId, commentId}`.
  - Draft "Tracked in [{ticket_key}]({ticket_url}) — will address in a follow-up."
  - Mark `resolve_after_push`.
- `s` Skip
  - Record in `skipped`.
  - Leave the thread open and untouched.
- `r` Rethink
  - Re-read the comment, surrounding code, and referenced context.
  - Produce deeper analysis with alternatives and risks.
  - Re-present the same comment with the same reserved options.

### After all decisions collected

Announce the transition to execution:

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

Apply all decisions collected in Step 5. Process `fixes_to_apply`,
`dismissals`, and `deferrals` in order.

### Issue-class scan before each fix

Before applying any fix, identify the issue class and grep the full PR diff for
sibling paths that could share the same class. Include matching sibling paths in
the same commit only when they belong to the same triage unit or were merged by
Step 4.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" | grep -nE '<class-pattern>' \
  | grep -v '<already-fixed-pattern>'
```

Pattern hints:

- Credential/token leaks: grep shell commands and stderr redirections, then subtract already-redacted lines.
- Validation/exception/retry gaps: grep the affected symbol plus every entry or call site.
- Race/TOCTOU: grep the resource path plus every read-then-write site.

### For each fix

1. Apply the code change using the Edit tool.
2. Verify with the repo's build/lint/test command. If no build system is
   detected, warn once. If verification fails, ask whether to fix, commit
   anyway, or skip this fix.
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

   In non-co-author sessions, omit the PR-author trailer. Use `Co-authored-by`
   only for real contributors.
4. Record the full commit SHA immediately:

   ```bash
   FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)
   ```

5. Update the drafted reply with a clickable commit link:

   ```markdown
   Fixed in [`<short>`](https://github.com/{owner}/{repo}/commit/{full_sha}) — {explanation}
   ```

   Derive the full SHA from git; never infer it from a short SHA.

### For each dismissal or deferral

No code change is needed. Use the reply drafted in Step 5. Deferrals reference
the user-provided ticket; do not create tickets inside this skill.

**Do NOT push after each commit.** Push all commits together in Step 8.

## Step 7: Confirm Everything

### Skip redundant confirmation when decisions are explicit

Step 5 decisions (`a`, `e`, `d`, `t`, `s`) are explicit user confirmation. Do
not re-ask "proceed?" after a fully decided Step 5. Proceed directly to the
adversarial-review gate and push.

The confirmation gate fires only when:

- An `(e)` edit was not echoed back verbatim for confirmation.
- A co-author session inferred the PR author's name or email instead of reading
  it from git log or PR metadata.
- Any ambiguous batch slipped into Step 5.

When the gate fires, ask:

> "Does this look correct? I will push {N} commits, post {M} threaded replies
> to individual review comments, resolve {R} threads, and leave {L} threads
> open for follow-up. Proceed? (yes / edit / abort)"

Be explicit that this skill posts threaded replies, not a formal PR Review.

### Resolution rule

Only threads in `resolve_after_push` are resolved. A thread lands there only
after a fix, explicit dismissal, or tracked deferral. Follow-up questions,
skipped threads, rethink-pending items, and ordinary self-review threads stay
open. Resolve submitted self-review threads only at merge readiness.

### Disambiguate "review" objections

If the user says "don't post the self-review", "skip the review", or similar,
ask whether they mean skipping a formal PR Review submission or skipping the
threaded replies. Default to the former unless they explicitly confirm the
latter.

## Step 8: Push and Respond

### Adversarial-review gate

Run `wk-adversarial-review` against the new commits before `git push`. Push is
conditional on a `clear` verdict or accepted `suggestions-only` A/B/C choice.
On `blocked`, address each blocker with a fresh atomic commit, re-invoke the
gate, and loop until clear.

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
- If cherry-pick conflicts or remote-only commits are rewritten duplicates,
  stop and surface to the user.

### Push commits

```bash
git push
```

If push is rejected as non-fast-forward, re-run reconciliation when no history
was rewritten. If history was rewritten, use the divergence guard's cherry-pick
recovery instead of rebasing. Never force-push.

### Sync PR description immediately after push

**HARD RULE:** After every push, update the PR body before posting replies or
resolving threads. Do this even when the body looks current. If there is no
drift, log an explicit "no drift detected" line that names the compared fields.

Preserve metadata lines. Verify commit links, test-plan checkboxes, CI status,
remaining work, known limitations, and file lists before deciding no drift.

### Re-check self-review and docs drift

On every push, re-read submitted self-review comments posted by the agent. If a
fix changed the code a comment describes, correct or resolve that comment.
Invoke `wk-docs` against files touched this session; update relevant docs,
specs, and README content when behavior, signatures, or config changed.

### Post replies, reactions, and resolve threads

Re-run the pending self-review check before the first reply. If a pending
review now exists, submit it as `COMMENT` before posting replies.

Post replies sequentially. Route by surface:

```bash
# Inline review comment
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"

# Review body or conversation comment
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --method POST -f body="{reply_text}"
```

Prefix issue-comment replies with a quote of the original comment.

Immediately add an emoji reaction to the original comment: `+1` for
`a`, `e`, or `t`; `-1` for `d`; `heart` for follow-up questions; no reaction
for `s` or `r`. Reaction failures are fire-and-forget; log and continue.

If an inline reply returns HTTP 404, log the failure and keep the thread in
`resolve_after_push`. REST comment IDs can be invalidated by force-push or bot
review replacement; GraphQL thread IDs are stable. Resolve via GraphQL thread
ID. If GraphQL resolution also fails, drop the thread and continue.

Refresh bot thread IDs before posting bot replies: re-run the GraphQL
reviewThreads query against post-push HEAD and match by `(path, line,
root_comment.body_excerpt)`. Skip replies for dropped findings.

Resolve threads with GraphQL:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_id}"
```

If GraphQL returns `NOT_FOUND`, refresh IDs once, match by stable identity, and
retry. If no match exists or retry fails, log and continue.

Detect in-place bot summary issue-comment updates by re-fetching each captured
bot issue comment. A transition from active findings to clean is a positive
resolution signal. A transition that adds findings is a regression and re-enters
Step 4.

Treat post-push comments matching `(path, line, concern)` from this session as
already-addressed echoes. Reply with the commit link, resolve the thread, and
do not re-prompt or re-commit.

## Step 9: Check Merge Conflicts

After pushing, verify no merge conflicts with the base branch:

```bash
git fetch origin
git merge --no-commit --no-ff origin/{base_branch} 2>&1
```

If clean, abort the test merge and report success. If conflicts are detected,
abort and ask whether to resolve them now.

## Step 9.4: Capture Adversarial-Review Learnings

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class
surfaced before entering the CI wait. Do not skip for short or routine
sessions. If zero findings were active, emit one baseline-holding learning.

Classify processed comments into generic issue classes such as security,
validation, exception handling, race/TOCTOU, retry/timeout, defensive/dead
guard, API/external-call shape, docs/rationale drift, comment accuracy drift,
or a new candidate class.

For each non-empty class, invoke:

```
Skill(wk-learn, args="adversarial-review")
```

Encode class, mechanism, detection sketch, and confidence. Use generic
patterns only; do not include file paths, line numbers, reviewer logins, or
commit SHAs from the PR.

If the post-CI loop surfaces genuinely new findings, re-run this step for that
batch before the next CI wait.

## Step 9.5: Wait for CI, Then Loop on New Comments

Delegate CI polling to the configured CI skill. Wait until the build reaches
`passed`, `failed`, or `canceled`. If CI failed or was canceled, surface the
failure and exit; fixing CI outranks further review feedback.

When CI passes, re-run Step 3 against the post-push HEAD. Compare the new
comment map to the session-local resolution map. Treat matching
`(path, line, concern)` comments as already-addressed echoes.

If genuinely new unresolved comments exist, loop:

1. Re-enter Step 4 for the new findings.
2. Re-enter Step 5 with the same partition and one-at-a-time rules.
3. Re-enter Steps 6–9 for the second cycle.
4. Re-enter Step 9.5 after the second push.

Exit only when CI passes and the post-CI fetch surfaces no genuinely unresolved
comments. Cap at three iterations; beyond that, surface the review-thrash loop
to the user.

## Step 10: Final Summary

Present a concise summary:

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

Invoke `wk-retro` to capture session-level learnings. This is mandatory on
every completion, including narrow directives. Step 11 covers session-level
reflection; adversarial-review learnings were emitted in Step 9.4.

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
