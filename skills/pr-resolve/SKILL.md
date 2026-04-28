---
name: wk:pr-resolve
description: >-
  Address PR review comments interactively — resolve feedback from reviewers by
  implementing fixes, preparing response comments, and managing the full
  resolution cycle. Use when asked to resolve PR comments, address review
  feedback, fix PR issues, respond to reviewers, or handle PR conversations.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh api repos:*)"
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
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - "Bash(mkdir -p:*)"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.04.28-193417'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
and manage the full resolution cycle from sync to summary.

## Hard Rules

1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
3. **Only resolve threads you actually worked on.** A thread is resolvable
   only if a fix was applied (option `a`/`e`), a comment was explicitly
   dismissed (option `d`), or a finding was deferred to a tracked ticket
   (option `t`). Never resolve follow-up questions (non-reserved letters
   like `f`), skipped threads (`s`), rethink-pending items (`r`), or
   self-review threads.
4. **Never force-push.** Use regular `git push` only.
5. **Never commit without attempting verification** (build/lint/test). If
   verification is unavailable or fails, inform the user before proceeding.
6. **Commits follow `wk:commit` conventions** — conventional format with
   emoji, signed commits, HEREDOC for messages. Never use `--no-gpg-sign`.
7. **One commit per resolved comment.** Each triaged comment gets its own
   commit so reviewers can trace exactly which commit addresses which
   comment. Never bundle multiple comments into one commit. Push only
   once at the end (Step 8) to avoid triggering multiple CI builds.
8. **Exclude self-review comments.** Never triage, suggest fixes for, or
   resolve threads where the root comment was authored by the PR owner
   OR the current user. Both are "self" — the PR author's own notes are
   not reviewer feedback, and the current user's prior comments are their
   own observations being acted on, not external review.
9. **Co-author attribution.** When the current user is not the PR author,
   include a `Co-authored-by:` trailer for the PR author in every commit.
   The user is resolving on behalf of the author — attribution must reflect
   both contributors.
10. **Include bot reviews.** Treat comments from bot accounts (Copilot,
   GitHub Actions, custom bots) as first-class review feedback. Triage
   them alongside human reviewer comments — evaluate each for correctness
   before accepting or dismissing.

## Step 1: Identify the PR

Determine the PR under review:

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,headRefOid
```

If on main/master or no PR is detected, ask the user for a PR number or URL.
Extract `{owner}`, `{repo}`, `{number}`, `{base_branch}`, and `{head_sha}`.

### Detect co-author scenario

```bash
PR_AUTHOR=$(gh pr view --json author --jq '.author.login')
CURRENT_USER=$(gh api user --jq '.login')
```

If `$PR_AUTHOR != $CURRENT_USER`, this is a **co-author session** — the
current user is resolving comments on someone else's PR. Record both
logins. Both are treated as "self" for comment exclusion (Hard Rule 8),
and the PR author gets `Co-authored-by:` attribution on every commit
(Hard Rule 9).

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

If co-author session:
> "Note: PR authored by @{pr_author}. Commits will include co-author
> attribution. Comments from both you and @{pr_author} are excluded
> from triage."

## Step 2: Sync Branch

Ensure the local branch is up to date with **both** the base branch and
the remote PR branch before fetching or triaging any feedback. Resolving
comments against a stale branch surfaces fixes that no longer apply
cleanly and can produce review replies that contradict the post-merge
state.

### Reconcile with the remote PR branch first

The remote PR branch can move independently of local (GitHub's "Update
branch" button, another session, a teammate pushing). If local has
commits not on the remote PR branch AND vice versa, integrating the
base alone creates divergent histories and the eventual push will be
rejected non-fast-forward.

```bash
git fetch origin
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)

if [ -n "$(git log --oneline HEAD..origin/$HEAD_BRANCH 2>/dev/null)" ]; then
  git rebase "origin/$HEAD_BRANCH"
fi
```

This keeps the next push fast-forward and avoids creating a second
merge commit that diverges from the remote.

### Integrate the base branch via `wk:pr-update`

Delegate base-branch integration to `wk:pr-update` rather than running
merge/rebase directly here. That skill picks the right strategy for
the branch's size (rebase for `<5` commits ahead, patch-replay
otherwise), runs the conflict-resolution loop, re-validates the work
post-integration (tests + cheap typecheck), and force-with-lease
pushes.

```
Skill(wk:pr-update, args="<base_branch>")
```

If `wk:pr-update` reports an unresolvable conflict and resets to the
starting SHA, **stop the resolve flow** — there's nothing to triage
on a branch that can't integrate base. Surface the conflict to the
user and exit; resume `wk:pr-resolve` after the user untangles
manually.

If `wk:pr-update` reports validation regression after integration,
also stop — fixing the regression is a higher-priority concern than
addressing review feedback on a broken branch.

If `wk:pr-update` reports the branch was already up to date
(`$BEHIND == 0`), continue immediately to Step 3.

### Why delegate

The merge/rebase + conflict + validation logic was previously inlined
here in shorter form. Delegating to `wk:pr-update` ensures every
update path uses the same strategy heuristics, the same safety net
(`$START_SHA` reset on failure), and the same PR sync rules — so a
PR-resolve update is indistinguishable from a manual `wk:pr-update`
run, and improvements to integration behavior apply everywhere.

## Step 3: Fetch Unresolved Comments

PR feedback lives on **three distinct GitHub surfaces**. Fetching only
inline review comments misses callouts that reviewers (and bots) place
in the other two surfaces. Fetch all three every run.

| Surface | Endpoint | What it holds |
|---------|----------|---------------|
| Inline review comments | `/pulls/{n}/comments` | Line-attached feedback (has `path` + `line`) |
| Review summary bodies | `/pulls/{n}/reviews` | Overall review text left alongside inline comments (no line anchor) |
| PR conversation (issue) comments | `/issues/{n}/comments` | Root-level discussion — top-of-PR callouts, bot summaries, ad-hoc requests |

Inline comments and their threads come from GraphQL + REST (below).
Review summary bodies and issue comments must be fetched separately —
they do not appear in `reviewThreads` or `/pulls/{n}/comments`.

### HARD RULE: three-surface pre-flight check

Before proceeding to Step 4, **every invocation** must have fetched
all three surfaces in the current run. Track explicit per-invocation
flags and refuse to advance until each is `true`:

```
inline_comments_fetched  = false
review_bodies_fetched    = false
issue_comments_fetched   = false
```

Cached results from a prior `wk:pr-resolve` invocation in the same
session do **not** count. Issue comments and review summaries can
appear at any time, including between invocations — most often the
top-of-PR description-drift bots fire late. Skipping a surface
because "we already looked at this PR earlier" loses high-severity
findings (description drift, title/body mismatch, missing test
counts) that don't surface anywhere else.

If any flag remains false (HTTP error, network failure, MCP/auth
issue), stop and report:

> "Step 3 incomplete: {surface(s)} not fetched. Re-run after fixing
> {error}, or proceed manually."

Never silently advance with partial fetches.

### HARD RULE: agent-observed drift is first-class feedback

If during Step 1 (PR view) or Step 3 (file/diff reads) the agent
notices PR drift the bots haven't flagged yet — stale title, stale
description, mismatched test counts, outdated `Closes #N` references,
contradictions between the body and the latest commits — treat that
observation as an active item in this run, **not** a side-offer to
the user.

Inject a synthetic comment into the comment map with:

- `surface: agent_observation`
- `reviewer: <agent>` (or the model name)
- `path`/`line`: the affected location, or `null` for whole-PR drift
- `body`: the observation, framed as a finding ("Title still says
  'block non-allowlisted' after the rename to denylist")
- `bot_badge` flag set so the comment renders as `🤖 (agent)` in
  Step 4's suggestion format

The triage flow (Step 4 classification, Step 5 consultation, Step 6
fix) handles it identically to any other finding. The agent often
sees drift before bots do; deferring to "wait for the bot to catch
up" is strictly worse than acting in the same run.

### Identify the PR author

Extract the PR author login from the `gh pr view` output (Step 1). This is
used to **exclude self-review comments** — threads where the root comment
was authored by the PR owner are skipped entirely.

### GraphQL — thread resolution status and IDs

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        author { login }
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 100) {
              nodes { id databaseId body path line author { login } }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F number={number}
```

### REST — full comment details

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, user_type: .user.type, author_association: .author_association, updated_at, in_reply_to_id}'
```

Note: `user_type` distinguishes humans (`User`) from bots (`Bot`).
`author_association` shows the commenter's relationship to the repo.

### REST — review summary bodies

Reviewers often leave a summary body alongside (or instead of) inline
comments. These bodies do not appear in `/pulls/{n}/comments`. Fetch
them separately:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate \
  --jq '.[] | select(.body != null and .body != "") | {id, state, body, user: .user.login, user_type: .user.type, submitted_at}'
```

Skip reviews with empty/null bodies (they carried only inline comments)
and reviews in state `PENDING` authored by the current user (see
pending self-review handling below). Include states `COMMENTED`,
`APPROVED`, and `CHANGES_REQUESTED` when the body is non-empty.

Replies to a review body are posted as **issue comments** (below), not
review-comment replies.

### REST — PR conversation (issue) comments

Top-of-PR callouts, bot summary comments (e.g., Copilot PR summary,
CI bots), and ad-hoc requests live in the issue-comments surface:

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate \
  --jq '.[] | {id, node_id, body, user: .user.login, user_type: .user.type, author_association: .author_association, created_at, updated_at}'
```

Issue comments have **no `path` or `line`** and cannot be resolved as
threads (there's no thread-resolution concept for them in GraphQL).
Replies are new issue comments posted to:

```
POST /repos/{owner}/{repo}/issues/{number}/comments
```

Treat each issue comment as a standalone item in triage — apply the
same author classification (bot / self / reviewer), the same
include/exclude rules, and the same triage options — but mark it as
`surface: conversation` so the resolution phase knows to post replies
via the issue-comments endpoint and to skip thread resolution.

### Classify comment authors

For each comment, classify the author:

| `user_type` | Pattern | Classification |
|-------------|---------|----------------|
| `Bot` | `*[bot]` suffix (e.g., `copilot[bot]`, `github-actions[bot]`) | **Bot review** |
| `Bot` | Custom bot names without `[bot]` suffix | **Bot review** |
| `User` | Matches PR author login | **Self-review** (skip) |
| `User` | Matches current user login (co-author session) | **Self-review** (skip) |
| `User` | Any other login | **Reviewer** |

### Pre-check: pending self-reviews

Before processing comments, check if the current user has a pending (draft)
review on this PR. A pending review blocks all reply-comment posting with
HTTP 422 (`user_id can only have one pending review per pull request`).

```bash
CURRENT_USER=$(gh api user --jq '.login')
PENDING_REVIEW_ID=$(gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  | jq --arg u "$CURRENT_USER" -r \
  '.[] | select(.state == "PENDING" and .user.login == $u) | .id')
```

**Note:** `gh api --jq` does not support jq CLI flags like `--arg`. When
you need `--arg`, pipe `gh api` output to `jq` directly. Using `--arg`
with `gh api` fails silently and returns empty results.

If a pending review exists, ask the user:

> "You have a pending (draft) self-review on this PR. Reply comments cannot
> be posted until it is submitted or dismissed. (a) Submit as COMMENT and
> continue, (b) Abort."

If (a), submit it:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews/$PENDING_REVIEW_ID/events \
  --method POST -f event=COMMENT
```

Do not proceed to comment processing until this is resolved.

### Build the comment map

For each GraphQL thread node:
- **Skip** if `isResolved == true`
- **Skip** if the root comment author matches the PR author login
  (self-review) — do not include self-review comments in the triage
- Match thread comments to REST comments by `databaseId == id`
- Extract root comment (no `in_reply_to_id`) and its reply chain
- Record: `{threadId, commentId, path, line, body, user, userType, replies[], isOutdated}`
- Tag threads where the root comment author is a bot (`isBot: true`)

### Filter active comments

A comment is **active** if:
- Thread is NOT resolved (`isResolved == false`)
- Root comment is NOT from the PR author (not self-review)
- Thread is NOT outdated (`isOutdated == false`), OR if outdated, the
  underlying concern is still present in the current code (verify by reading
  the file at the referenced path and line)

Skip truly outdated comments where the code has been rewritten and the
concern no longer applies. Note these as "auto-skipped" in the summary.

### Surface feedback hidden in self-review threads

When skipping a self-review thread (root comment by the PR author), scan its
replies for comments from other users. If any exist, collect them for the
final summary — do NOT triage, fix, or resolve them; just surface them so
the user knows they exist and can address them out-of-band.

Track as `self_review_with_external_replies`:
`{user, path, line, one-line body preview}`.

### Group by file

Sort active comments by file path, then by line number within each file.
Separate bot comments from human reviewer comments in the summary:

> "Found X unresolved comments across Y files (Z auto-skipped as outdated,
> S skipped as self-review)."
>
> **Bot reviews:**
> **src/auth.ts** (2 comments from copilot[bot])
>
> **Reviewer comments:**
> **src/auth.ts** (1 comment from @reviewer1)
> **src/api.ts** (1 comment from @reviewer2)
> **src/utils.ts** (2 comments from @reviewer1)

## Step 4: Generate Suggestions

Process bot reviews first (they often flag actionable issues like style
violations, security concerns, or code suggestions), then human reviewer
comments.

For each active comment, in file-grouped order:

1. Read the full file (not just the diff hunk) to understand context
2. Read the reviewer's comment and full reply chain
3. Analyze what the reviewer is asking for
4. Generate a concrete suggested fix — actual code changes, not vague advice

### Bot review handling

Bot comments (Copilot, custom bots, CI bots) often include:
- **Code suggestions** (Copilot): Extract the suggested diff and present it
  as a concrete fix. Evaluate whether the suggestion is correct before
  recommending it — bots can be wrong.
- **Lint / style violations**: Map the violation to a specific fix.
- **Security warnings**: Treat seriously — read the flagged code and verify
  the concern. If valid, propose a fix. If a false positive, draft a
  dismissal reply explaining why.
- **Automated analysis**: Summarize the bot's finding and propose an action.

Do NOT blindly accept bot suggestions. Evaluate each one for correctness.

### Suggestion format

For each comment, prepare a structured suggestion. Every suggestion MUST
include reasoning for both applying and discarding:

```
### Comment {n}/{total}: {path}:{line}
**Reviewer:** @{user} {bot_badge}
**Comment:** {body}
**Reply chain:** {summary of any replies, or "none"}

**Suggested fix:** {What to change — concrete code diff or snippet}

**Why this fix:** {What problem it solves, what the reviewer is concerned
about, and why this approach addresses it}

**Why this could be skipped:** {Valid reason to discard — e.g., false
positive, stylistic preference not enforced by the project, already
handled elsewhere, out of scope for this PR, or "No valid reason to
skip — this is a real issue that should be fixed"}
```

Where `{bot_badge}` is `🤖 (bot)` if the commenter is a bot, omitted
otherwise.

Be honest in the skip rationale. If there is no good reason to skip,
say so explicitly — do not fabricate a dismissal justification.

### Classify each suggestion: obvious-fix vs judgment-required

After preparing the suggestion, tag it with a classification that
controls how Step 5 presents it. The goal is to keep one-at-a-time
consultation for real decisions while removing ceremony from
mechanical fixes.

| Tag | Condition | Examples |
|-----|-----------|----------|
| `obvious-fix` | "Why this could be skipped" reduces to "no valid reason" / empty / "broken link" / "stale reference"; OR the fix mechanically follows from a previous user-approved change in the same PR (rename cleanup, inversion cleanup, renamed-symbol references) | Broken link to a renamed spec, env var that contradicts the PR's own stated rename, missed reference after a global rename |
| `judgment-required` | Real tradeoff, false-positive possibility, scope question, multiple valid approaches, security/perf judgment, anything where a thoughtful reviewer would push back | Suggested API change, alternative algorithm, scope-creep request, "is this even a bug?" |

Default to `judgment-required` when uncertain — false negatives here
(asking when you didn't need to) are cheap; false positives
(auto-applying something that needed review) are expensive.

## Step 5: Consult — Collect All Decisions First

**HARD RULE: Do NOT touch code during this step.** This is a
consultation-only phase. Present each `judgment-required` comment one
at a time, collect the user's decision, then move to the next. No
edits, no commits, no replies — just decisions.

### Auto-apply preview for obvious-fix comments

Before per-comment consultation, bundle every `obvious-fix` suggestion
(from Step 4 classification) into a single preview block:

> "**Auto-apply queue ({K} obvious fixes — no judgment needed):**
>
> 1. {path}:{line} — {one-line summary} (skip rationale: {empty / no
>    valid reason})
> 2. ...
>
> These will be applied as-is during Step 6, one commit each per Hard
> Rule 7. Reply **all-review** to instead consult on each one
> individually, or proceed without reply to keep the queue."

Wait briefly for an `all-review` override, then move to per-comment
consultation for `judgment-required` items only. Apply the
`obvious-fix` queue in Step 6 with no further prompts (still one
commit per finding; replies + thread resolution as normal).

If **all** active comments are `obvious-fix`, present the preview and
skip Step 5's per-comment loop entirely — proceed to Step 6 after the
override window closes.

### Present one at a time

For each suggestion (prepared in Step 4), present it using the full
suggestion format including "Why this fix" and "Why this could be
skipped" reasoning. Then ask:

> **Comment {n}/{total}:** How would you like to handle this?
> **(a)** Apply the suggested fix
> **(e)** Edit the suggested fix (describe how to adjust it)
> **(d)** Dismiss — not applicable / false positive (explain why)
> **(t)** Defer to ticket — track in a follow-up issue/ticket instead of fixing in-PR
> **(s)** Skip — leave as-is without resolving
> **(r)** Rethink — re-analyze this comment more thoroughly before deciding
> {additional context-specific options using non-reserved letters}

The letters `a`, `e`, `d`, `t`, `s`, `r` are **reserved** and must always
mean the same thing across every comment. If the agent adds extra options
based on the comment's content (e.g., "(f) Ask the reviewer a follow-up
question", "(o) Open the file to investigate"), those MUST use letters
outside the reserved set. Never redefine a reserved letter.

Wait for the user's response before presenting the next comment.

**HARD RULE: one comment per message — never batch.** Emit exactly one
`Comment {n}/{total}` block per message, then stop and wait for the
reply. Only after receiving the reply may the next comment be
presented. Do not combine 2+ comments into a single message, even when
they look related, are all likely dismissals, or auto mode is active.

Auto mode does **not** suspend this rule. Auto mode means executing
without pausing for permission on low-risk work; it does not mean
collapsing the one-at-a-time consultation pattern. Single-letter
replies are ambiguous across batches — the user cannot signal
per-comment decisions when multiple prompts share one response slot.

If you feel pulled to batch ("to save round-trips", "they're all the
same category"), do not — one per message, always.

### Record each decision (do not execute yet)

**(a) Apply suggested fix:**
- Record in `fixes_to_apply` list: `{path, line, description, code_change, threadId, commentId}`
- Draft reply: "Fixed — {brief explanation}" (commit link added in Step 6)
- Mark for `resolve_after_push`

**(e) Edit the suggested fix:**
- Ask: "How would you like to adjust the fix?"
- Record the user's refinement in `fixes_to_apply` with the adjusted
  approach
- Draft reply based on the adjusted fix
- Mark for `resolve_after_push`

**(d) Dismiss (bot or human reviews):**
- Ask: "Why are you dismissing this comment?" — require an explanation
- Record dismissal reason in `dismissals` list
- Draft reply: "Dismissed — {reason}" (do not soften to "false positive"
  unless the user said so)
- Mark for `resolve_after_push`

**(t) Defer to ticket:**
- Ask: "What's the ticket URL or key tracking this work?" — require a
  reference (Jira key, GitHub issue URL, or similar). If the user has
  not yet filed one, offer to draft it but do not create the ticket
  inside this skill — defer ticket creation to the user.
- Record in `deferrals` list: `{path, line, ticket_url, ticket_key, threadId, commentId}`
- Draft reply: "Tracked in [{ticket_key}]({ticket_url}) — will address
  in a follow-up." (substitute the URL/key the user provided)
- Mark for `resolve_after_push`

**(s) Skip:**
- Record in `skipped` list — no fix, no reply, no resolution
- The thread stays open and untouched

**(r) Rethink:**
- Re-read the comment, the surrounding code, and any referenced
  context. Produce a fresh, deeper analysis of the suggestion,
  including: the reviewer's likely concern, alternative fixes, risks of
  each, and a stronger recommendation. Then re-present the comment
  with the revised analysis and the same reserved options. `r` is not
  itself a decision — it returns to the prompt.

**Additional options (non-reserved letters):** The agent may add extras
when the comment warrants them — e.g., "(f) Ask the reviewer a
follow-up question", "(o) Open the referenced file". Record these in
the matching list (`reply_only`, etc.) and document the letter used.
For deferring to a follow-up ticket, use the reserved `(t)` option —
do not invent a non-reserved letter for that path.

### After all decisions collected

Announce the transition to execution:

> "All {total} comments reviewed. Decisions collected:
> - {apply_count} fixes to apply (option `a`/`e`)
> - {followup_count} follow-up questions to post (non-reserved options)
> - {dismiss_count} dismissals (option `d`)
> - {defer_count} deferrals to follow-up tickets (option `t`)
> - {skip_count} skipped (option `s`)
>
> Moving to implementation — I'll apply fixes, verify, and commit each one."

## Step 6: Execute — Apply Fixes, Verify, and Commit

**Now** apply all decisions collected in Step 5. Process each entry in
`fixes_to_apply` and `dismissals` in order.

### For each fix (option `a` or `e`)

1. **Apply the code change** using the Edit tool
2. **Verify** — detect the project's verification command and run a check:

   ```bash
   # Try common build/lint commands (use first found)
   [ -f package.json ] && npm run lint --if-present 2>&1 | tail -20
   [ -f Makefile ] && make check 2>&1 | tail -20
   [ -f Cargo.toml ] && cargo check 2>&1 | tail -20
   ```

   If verification fails, present the error and ask:
   > "Verification failed for fix {n}. (a) Fix the issue, (b) commit
   > anyway, (c) skip this fix?"

   If no build system is detected, warn once:
   > "No build/lint command detected — skipping verification."

3. **Commit** — one commit per resolved comment:

   ```bash
   git add {files}
   git commit -m "$(cat <<'EOF'
   fix(scope): 🐛 {brief description of what this comment asked for}

   Addresses review comment by @{reviewer} on {path}:{line}

   Co-Authored-By: {agent-name} <noreply@example.com>
   EOF
   )"
   ```

   **Co-author session:** When the current user is not the PR author,
   add a `Co-authored-by:` trailer for the PR author:

   ```
   Co-authored-by: {pr_author_name} <{pr_author_email}>
   Co-Authored-By: {agent-name} <noreply@example.com>
   ```

   Fetch the PR author's name and email from the PR or git log. If
   unavailable, use their GitHub login and `{login}@users.noreply.github.com`.

4. **Record the commit SHA** and update the drafted reply to include the
   commit as a **markdown link** to the commit URL — bare short SHAs do
   not render as clickable links in the GitHub PR UI, forcing reviewers
   to hunt for the commit manually. Always link:

   ```markdown
   Fixed in [`abc1234`](https://github.com/{owner}/{repo}/commit/{full_sha}) — {explanation}
   ```

   Use the full 40-char SHA in the URL and the 7-char short SHA in the
   link text. This rule applies to **every** reply comment that
   references a commit, not only the first — if a single reply mentions
   multiple commits, link each one.

Use the commit type that matches the nature of the change: `fix` for bug
fixes, `refactor` for restructuring, `feat` for new behavior. Always
include the emoji per `wk:commit` conventions.

### For each dismissal (option `d`)

No code change needed. The drafted reply was already prepared in Step 5.

### For each deferral (option `t`)

No code change needed. The drafted reply (referencing the tracked
ticket) was already prepared in Step 5. The reply will be posted in
Step 8 along with all other replies, and the thread will be resolved.
Do not file the ticket inside this skill — that is the user's
responsibility.

**Do NOT push after each commit.** All commits are pushed together in
Step 8 as a single `git push`, so only one CI build is triggered.

## Step 7: Confirm Everything

After ALL comments are processed, present a full summary:

```
## Resolution Summary

### Fixes applied ({count} commits)
1. abc1234 — fix(auth): 🐛 invalidate session on logout
   - Addresses: @reviewer src/auth.ts:42, src/auth.ts:58

2. def5678 — refactor(api): ♻️ extract timeout config
   - Addresses: @reviewer2 src/api.ts:33

### Bot reviews addressed ({count})
3. src/auth.ts:15 — copilot[bot]: applied suggested null check
4. src/api.ts:22 — copilot[bot]: dismissed (false positive)

### Reply comments to post ({count})
1. src/auth.ts:42 → "Fixed in [`abc1234`](https://github.com/{owner}/{repo}/commit/{full_sha}) — session now invalidated on logout"
2. src/api.ts:33 → "Extracted to config — timeout is now configurable"
3. src/auth.ts:15 → "Applied — added null check as suggested"
4. src/api.ts:22 → "False positive — value is guaranteed non-null by L18"

### Follow-up questions ({count})
5. src/utils.ts:18 → "Could you clarify whether you mean..."

### Threads to resolve ({count})
- src/auth.ts:42, src/auth.ts:58, src/api.ts:33, src/auth.ts:15, src/api.ts:22

### Threads left open ({count})
- src/utils.ts:18 (follow-up question)
- src/models.ts:9 (skipped)

### Self-review threads excluded ({count})
- src/config.ts:5, src/config.ts:12 (PR author's own comments — not touched)
```

**Resolution rule:** Only threads in `resolve_after_push` are resolved.
A thread lands in that list **only** when a fix was applied (`a`/`e`),
a comment was explicitly dismissed (`d`), or a finding was deferred to
a tracked ticket (`t`). Threads with follow-up questions (non-reserved
letters), skipped threads (`s`), rethink-pending items (`r`), and
self-review threads are **never** resolved.

Ask:
> "Does this look correct? I will push {N} commits, post {M} **threaded
> replies to individual review comments** (not a formal PR Review),
> resolve {R} threads, and leave {L} threads open for follow-up.
> Proceed? (yes / edit / abort)"

Be explicit about the difference between **threaded replies** (posted via
`/comments/{id}/replies`, one per reviewer comment) and a **formal PR
Review** (an aggregate review object posted via `/reviews`). This skill
only posts the former; it never submits a formal PR Review.

### Disambiguate "review" objections

If the user responds with language that could refer to either kind of
posting — e.g., "don't post the self-review", "skip the review", "no
review" — **do not** silently skip all reply comments. Ask a clarifying
question first:

> "To confirm: do you mean (a) skip posting a formal PR Review
> submission (this skill doesn't do that anyway), or (b) skip the {M}
> threaded replies to individual review comments?"

Default interpretation when ambiguous: the user means (a). Proceed with
threaded replies unless they explicitly confirm (b).

Wait for explicit confirmation. If "edit," ask what to change. If "abort,"
stop without pushing or posting anything.

## Step 8: Push and Respond

**Only after explicit user confirmation.**

### Push commits

```bash
git push
```

If push is rejected as non-fast-forward, the remote PR branch moved
during this session. Re-run the Step 2 reconcile (`git fetch origin`
then `git rebase origin/{head_branch}`) and push again. Never
force-push. If the rejection is for any other reason, tell the user
and ask how to proceed.

### Update PR description

**HARD RULE: after every push in this skill, sync the PR description.**
Fixes applied and changes pushed during a resolve session invalidate
prior claims in the body (commit counts, file lists, "remaining work"
sections, linked commits). An out-of-date description misleads
reviewers and future readers. This step is non-optional even when the
body looks "roughly correct."

Sync the body to reflect all commits pushed in this session — correct
any stale counts, mention fixes applied, link the new commits as
markdown URLs (not bare SHAs), and ensure the body matches the current
branch state.

**Before overwriting**, read the current body and carry forward metadata lines:
`Closes #N` / `Fixes #N` / `Resolves #N`, `Co-authored-by:` lines, and any
automation-generated blocks (`**Build:**`, `<details>` context). These are
metadata, not prose — dropping them silently breaks issue auto-closing.

```bash
gh pr edit {number} --body "$(cat <<'EOF'
{updated description with metadata preserved}
EOF
)"
```

This mirrors the `wk:pr` rule: after every push to a branch with an existing
PR, the description must be updated.

### Causes of 404 on reply posting

REST inline-reply posting (`POST /pulls/{n}/comments/{id}/replies`) can
return **404 Not Found** for the comment ID even when the underlying
review thread still exists. Two known causes:

1. **Force-push during this session** (e.g., after a rebase in Step 2)
   may invalidate existing review comment threads.
2. **Bot review replacement** — bots like `{bot}`,
   `copilot[bot]`, and similar review automation often replace their
   entire review object on each push, which destroys the previous
   comment IDs even though the thread node ID (`PRRT_...`) survives.

REST comment IDs are unstable; GraphQL thread node IDs are stable.
When a 404 is returned, the thread itself may still be valid for
resolution via GraphQL (`resolveReviewThread`).

This is expected and non-fatal — log the failure, but try to resolve
the thread by node ID before giving up (see "Post reply comments"
below). Continue with the remaining replies regardless.

### Post reply comments (sequentially)

Post replies **one at a time, in order**. Do NOT post in parallel — a
404 on one reply must not cancel the remaining replies.

Route each reply by its comment's `surface`:

**`surface: inline`** (review comments, has `path` + `line`):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{reply_text}"
```

**`surface: review_body`** (reply to a review summary body) and
**`surface: conversation`** (reply to a top-of-PR / issue comment) both
post to the issue-comments endpoint — GitHub has no threaded-reply
endpoint for these surfaces:

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments \
  --method POST -f body="{reply_text}"
```

When posting to the issue-comments endpoint, prefix the reply body with
a quote referencing the original comment so the thread remains readable
(GitHub does not render these as threaded replies). Example:

```
> @{original_author} wrote: {one-line excerpt}

{your reply text}
```

If the inline API returns **404**:
- Log: "Reply to comment {comment_id} on {path}:{line} returned 404
  (thread likely invalidated by force-push or bot review replacement)."
- The reply text is lost, but the **thread itself may still exist**
  via its GraphQL node ID. Keep the thread in `resolve_after_push` —
  the GraphQL `resolveReviewThread` mutation in the next phase uses
  the thread node ID (`PRRT_...`), which is stable across review
  replacement and force-push, and will succeed even when the REST
  comment ID is dead.
- If the GraphQL resolve also returns an error, only then drop the
  thread from `resolve_after_push` and continue.
- Continue with the next reply

If any API returns another error, report it to the user and ask how
to proceed.

### Resolve threads

For each thread in `resolve_after_push` (NOT in `reply_only`):

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="{thread_id}"
```

If resolution returns an error (thread invalidated), log and continue.

**HARD RULE: Never resolve threads in the `reply_only` list.** Those have
follow-up questions and must stay open for the reviewer to respond.

Report progress as each action completes.

## Step 9: Check Merge Conflicts

After pushing, verify no merge conflicts with the base branch:

```bash
git fetch origin
git merge --no-commit --no-ff origin/{base_branch} 2>&1
```

If clean:

```bash
git merge --abort 2>/dev/null  # clean up the test merge
```

> "No merge conflicts with `{base_branch}`. You're clear."

If conflicts are detected:

```bash
git merge --abort
```

> "Merge conflicts detected with `{base_branch}` in: {file list}.
> Would you like me to resolve them now?"

## Step 10: Final Summary

Present a concise summary of everything done:

```
## PR #{number} Review Resolution Complete

**Branch synced:** ✓ Up to date with `{base_branch}`
**Comments processed:** {total} of {total_found}
**Self-review excluded:** {count} (PR author's own comments)
**Feedback in self-review threads:** {count} ({user}, {path}:{line} — {body preview} — not triaged, address out-of-band)
**Bot reviews handled:** {count} ({applied} applied, {dismissed} dismissed)
**Reviewer fixes:** {count}
**Deferred to tickets:** {count} ({ticket_list})
**Commits pushed:** {count} ({commit_list})
**Replies posted:** {count}
**Threads resolved:** {count} (fixes applied, dismissals, or deferrals)
**Threads left open:** {count} (follow-ups: {f}, skipped: {s})
**Merge conflicts:** None / {details}

PR URL: {url}
```

## Step 11: Session Retro

After the final summary, invoke `wk:retro` to capture session learnings.
This is mandatory — do not skip even if the session was short or routine.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "resolve PR comments" | Full workflow |
| "address review feedback" | Full workflow |
| "fix PR #{number}" | Full workflow for specific PR |
| "respond to reviewers" | Full workflow with focus on replies |
| Session ends | Invoke `wk:retro` |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running verification commands
- Commit signing configured (GPG or SSH)

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
mkdir -p "$WK_SKILLS_HOME/learnings/skills/pr-resolve"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/pr-resolve/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:pr-resolve
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

> "📝 Learning captured: `pr-resolve/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
