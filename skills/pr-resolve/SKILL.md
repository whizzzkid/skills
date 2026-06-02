---
name: wk-pr-resolve
description: >-
  Address PR review comments interactively — resolve feedback from reviewers by
  implementing fixes, preparing response comments, and managing the full
  resolution cycle. Use when asked to resolve PR comments, address review
  feedback, fix PR issues, respond to reviewers, or handle PR conversations.
  Also auto-activate on indirect references — "fix the comment", "there's a
  description/comment issue", "address the feedback", "fix this on the PR" —
  whenever an open PR exists on the current branch (one was created or worked
  on earlier this session). Prefer activating over asking a clarifying
  question; the open PR is the implied target.
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
model: opus
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.06.02-221022'
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

0. **All GitHub reads/writes route through `wk-gh`.** Org scoping
   per `wk-gh` Step 1–2; every reply comment body, PR body edit,
   and thread message ends with the canonical outbound footer per
   `wk-gh` Step 4 — applied at payload-render time.
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
6. **Commits follow `wk-commit` conventions** — conventional format with
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
   - **User-touched reviewer threads — narrow follow-up allowed.** On a
     reviewer or bot thread where the root is **not** self but the
     current user has already posted a reply, the agent may post one
     follow-up comment **only if** (a) a fix in this session changed
     the finding, or (b) a new item not covered by the user's reply
     needs explicit callout. Still requires explicit user confirmation
     per Hard Rule 2. Never resolve the thread on the back of a
     follow-up comment — resolution rights come from working the fix,
     not from commenting (Hard Rule 3).
   - **Off-limits.** Reviewer or bot threads where the current user
     has posted no reply remain untouchable for new agent comments.
9. **Co-author attribution.** When the current user is not the PR author,
   include a `Co-authored-by:` trailer for the PR author in every commit.
   The user is resolving on behalf of the author — attribution must reflect
   both contributors.
10. **Include bot reviews.** Treat comments from bot accounts (Copilot,
   GitHub Actions, custom bots) as first-class review feedback. Triage
   them alongside human reviewer comments — evaluate each for correctness
   before accepting or dismissing.
11. **Adversarial-review gate before push.** Any new commits produced in
   this session (Step 6 fixes, re-fixes after CI, follow-up commits) must
   pass `wk-adversarial-review` before Step 8's `git push`. The gate
   catches the recurring back-and-forth classes — vulnerability-class
   fixes left on one site, sibling-script drift, dead defensive guards,
   stale comments, PR-metadata drift — that this skill historically
   surfaced only after another reviewer round. Blocked verdict means no
   push; fix and re-invoke until clear.
12. **Implement handoff documents before deleting them.** When the branch
   contains a handoff doc — `RUN_LOCALLY.md`, `NEXT_PHASE.md`, `HANDOFF.md`,
   `TODO.md`, or any filename whose name signals remaining work — read it
   fully and implement every item it describes **before** removing it. Delete
   it only in the same commit as the last implementation change, never as a
   standalone cleanup. If the remaining work is large or spans repos, present
   a plan to the user first. Deleting a handoff doc as "cleanup" silently
   drops the work it tracked.

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

### Integrate the base branch via `wk-pr-update`

Run a merge-aware pre-check before delegating. When HEAD already
contains a merge commit from the base and `$BEHIND` is small, the
right action is a plain `git merge "$BASE_REF"` — delegating to
`wk-pr-update` would route through patch-replay strategy selection
that overstates the work and risks squashing already-reviewed commits:

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
  git merge "origin/$BASE"   # trivial merge-style integration
fi
```

For all other cases, delegate base-branch integration to `wk-pr-update`
rather than running merge/rebase directly here. That skill picks the
right strategy for the branch's size (rebase for `<5` commits ahead,
patch-replay otherwise), runs the conflict-resolution loop,
re-validates the work post-integration (tests + cheap typecheck), and
force-with-lease pushes.

```
Skill(wk-pr-update, args="<base_branch>")
```

If `wk-pr-update` reports an unresolvable conflict and resets to the
starting SHA, **stop the resolve flow** — there's nothing to triage
on a branch that can't integrate base. Surface the conflict to the
user and exit; resume `wk-pr-resolve` after the user untangles
manually.

If `wk-pr-update` reports validation regression after integration,
also stop — fixing the regression is a higher-priority concern than
addressing review feedback on a broken branch.

If `wk-pr-update` reports the branch was already up to date
(`$BEHIND == 0`), continue immediately to Step 3.

### Why delegate

The merge/rebase + conflict + validation logic was previously inlined
here in shorter form. Delegating to `wk-pr-update` ensures every
update path uses the same strategy heuristics, the same safety net
(`$START_SHA` reset on failure), and the same PR sync rules — so a
PR-resolve update is indistinguishable from a manual `wk-pr-update`
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

### Three-surface pre-flight check

**HARD RULE:** Before proceeding to Step 4, **every invocation** must have fetched
all three surfaces in the current run. Track explicit per-invocation
flags and refuse to advance until each is `true`:

```
inline_comments_fetched  = false
review_bodies_fetched    = false
issue_comments_fetched   = false
```

Cached results from a prior `wk-pr-resolve` invocation in the same
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

### Agent-observed drift is first-class feedback

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

See `skills/pr-resolve/references/graphql-review-threads.md` for the canonical query.

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
| `Bot` | `*[bot]` suffix (e.g., `dependabot[bot]`, `github-actions[bot]`) | **Bot review** |
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
> **src/feature.ts** (2 comments from {review-bot}[bot])
>
> **Reviewer comments:**
> **src/feature.ts** (1 comment from @{reviewer-a})
> **src/service.ts** (1 comment from @{reviewer-b})
> **src/utils.ts** (2 comments from @{reviewer-a})

## Step 4: Generate Suggestions

### HARD RULE — detect bot re-review thrash before another fix cycle

Track `(path_prefix, concern_class)` pairs across successive bot review rounds
on this PR. After **3 re-fires** of the same pair within this session, stop and
ask the user before generating another fix:

```bash
# concern_class derives from the comment body's top-level tag —
# e.g., "missing nil check", "unused variable", "potential XSS",
# "style: trailing whitespace". Path prefix is the file's directory.
```

- The counter resets when the pair is acknowledged-dismissed-with-rationale
  or when the user picks a follow-up ticket.
- Three re-fires signals one of: the fix is wrong, the bot has a stale snapshot,
  or the concern is structural and not fixable in this PR.
- On the 3rd re-fire, present:

  > "Bot has re-raised `<concern_class>` under `<path_prefix>` 3 times. Pick:
  > (a) investigate root cause now, (b) defer to follow-up ticket, (c) dismiss
  > with rationale on the thread."

- Do not auto-pick. The thrash gate is user-driven; silent loop continuation
  is the failure mode this rule exists to prevent.

### Order of processing

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

### Query the internal knowledge base before answering org-specific questions

When a reviewer comment is a **question** that touches org-specific
policy (retention, quotas, billing, infra config, compliance, SLAs,
internal tooling), search the configured internal knowledge-base MCP
before drafting the reply. Generic vendor knowledge is the wrong
default — internal docs are authoritative.

- Use `ToolSearch` to find a configured KB tool (e.g. Glean,
  Notion, Confluence MCP) and search for the relevant doc.
- If the KB surfaces an authoritative doc, cite it verbatim in the
  reply (title + link) and quote the load-bearing sentence.
- Fall back to general vendor knowledge only if the KB returns
  nothing relevant. Flag that fallback in the reply so the
  reviewer can override.
- Skip this step for non-policy questions (code-level intent,
  design rationale, test coverage) — those belong in the diff,
  not the KB.

### Verify "missing documentation" bot findings against repo docs

Before surfacing a bot finding that claims a behavior, design decision,
or trade-off is undocumented (typical phrasing: "description-check",
"missing context", "explain why", "document the rationale"), confirm
the claim against the repo itself. Surfacing the consultation without
this check forces the user to re-clarify what the agent could have
found.

- Grep the diff and `docs/specs/`, `docs/plans/`, `docs/adr/`, and any
  in-code design block referenced by the touched files for the
  behavior the bot calls out.
- If the docs already cover it, include the reference inline in the
  suggestion (`spec already covers this at docs/specs/<file>.md`) and
  default the suggestion to `dismiss-with-reference`.
- If the docs do not cover it, present the consultation normally —
  the bot's flag is accurate.
- Skip the consultation entirely when the answer is unambiguous from
  reading the touched code (e.g., the rationale is in a sibling
  comment block). Note the reference and dismiss.

### Bot-native reply syntax

Many review bots accept **structured commands** in reply comments
that close their findings cleanly — `@<bot> <action> <finding-id>
<reason>`. Generic freeform replies leave the finding open and add
noise to the thread.

- Before drafting a reply, check the bot's own documentation or its
  comment template for a documented command grammar.
- Detect the bot by login (e.g., `*[bot]` author) and look for a
  stable finding identifier in the comment body (typical shape:
  `<prefix>_<hex>` or a numbered ID).
- Reply via `/issues/{n}/comments` (issue comment surface) when the
  bot reads from there — most security/policy bots do, not the
  inline review-comment thread.
- Map the user's decision to the bot's action vocabulary:
  - "false positive" → the bot's `fp` / `false-positive` / `dismiss`
    command.
  - "low impact" → the bot's `nit` / `acknowledge` / `info` command.
  - "fixed in commit" → the bot's `resolved` / `fixed` command (if
    supported); otherwise drop a reply pointing to the SHA.
- Include the finding ID verbatim. Bots reject the command when the
  ID is missing or malformed.
- Concrete shape — a security bot that publishes findings with stable
  IDs (e.g. `<prefix>_<hex>`) and accepts structured replies:

  ```
  @<bot> fp <finding-id> <reason>
  @<bot> nit <finding-id> <reason>
  ```

- For bots without a documented command surface, fall back to the
  generic dismissal reply but tag the bot in the body so the
  thread is visibly addressed.

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

### Check whether the comment exposes a design flaw

Before drafting the suggested fix as a localized patch to whatever
the reviewer pointed at, decide whether the comment is actually a
**design signal** about the surrounding code. Reviewers often
phrase a structural concern as a narrow line-level observation;
treating it as line-level loses the signal.

Trigger phrases / patterns that mean **"the design is fragile,"**
not "this line needs a tweak":

- "this might not trigger" / "this branch is never hit in {context}"
- "this depends on X being correctly set" (external/upstream
  invariant)
- "what happens if {edge case the code can't actually distinguish}"
- "why do we need this {check / branch / fallback} at all"
- "this is duplicated with / contradicts {another path}"
- "the contract here is unclear" / "I don't understand when this
  fires"

When the comment matches one of these, the **primary suggested fix**
is a design change — typically removing the fragile branch,
inverting a conditional, lifting an invariant up to the caller,
collapsing two paths into one, or extracting a clearer contract.
A clarifying reply is the **secondary** option, not the lead.

Format the suggestion to make the design option visible:

```
**Suggested fix (primary — design):** <Remove/restructure/invert>
**Why this fix:** <The structural problem the reviewer's
observation pointed at, even if they framed it as a line-level
question.>

**Suggested fix (secondary — clarify):** <One-paragraph reply
explaining the current design's intent, IF the design is actually
correct and the reviewer just needs context.>
```

In Step 5's per-comment consultation, present the design option
first. The reserved letters keep their meaning: `(a) Apply the
suggested fix` selects the design option as drafted; the user can
pick `(e) Edit` to choose the clarifying reply or shape the design
fix differently.

The lead-with-explanation failure mode is common because writing a
clarifying reply is cheaper than reworking the code — but if the
reviewer was pointing at a real fragility, the explanation
preserves the bug. Bias toward design changes when the trigger
phrases above appear.

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

**The classification key is the skip rationale, not the change
shape.** A design change can be `obvious-fix`, a rename can be
`judgment-required` — it depends entirely on whether there is a
real tradeoff worth weighing. Before tagging anything
`judgment-required`, re-read the agent's own "Why this could be
skipped" rationale. If it contains any of:

- "no valid reason"
- "no good reason to skip"
- "—" / empty
- any phrasing that effectively concedes the comment is right and
  there is nothing to weigh

…the tag is **`obvious-fix`**, regardless of whether the change is
mechanical, design-level, refactor-shaped, or touches multiple
files. Words like "design," "refactor," or "structure" are not
reflex triggers for `judgment-required`. The check is: would the
agent push back on this finding if it were doing the review
itself? If no, `obvious-fix`. If yes (with a meaningful
counterargument), `judgment-required`.

**HARD RULE:** Immediately before emitting **any**
Step 5 consultation prompt — not only `(d) Dismiss` — re-read the
comment's "Why this could be skipped" rationale. If it is empty,
"no valid reason," "no good reason to skip," `—`, or any phrasing
that concedes the comment is right with nothing to weigh, the
prompt must not be emitted. Re-tag the comment as `obvious-fix`
and route it to the bulk-apply queue. Per-comment consultation is
reserved for items with a real tradeoff — emitting `(a)/(e)/(d)/(s)`
for a comment whose own rationale says there is nothing to skip
forces the user to answer `a` for ceremony.

**Severity is not a bypass.** A bot or reviewer finding marked Major /
blocker / critical with an empty "no valid reason" skip rationale is
still `obvious-fix` — apply it directly, do not emit a prompt. High
severity raises the fix's *priority*, never the need for confirmation.
The recurring failure is pattern-matching "bot finding + high severity"
and routing to consultation despite the rationale; the rationale, not
the severity, decides whether a prompt is owed.

### Merge duplicate findings on the same line

When two or more comments target the **same `path:line` with the
same concern** (different reviewers — e.g., one bot finding plus
one human reviewer, or two bots flagging the same issue), merge
them into a **single suggestion block** rather than generating one
suggestion per comment.

Format the merged suggestion citing every original reviewer:

```
### Comment {n}/{total}: {path}:{line}
**Reviewers:** @{reviewer-a} 🤖, @{reviewer-b} 🤖
**Comments:** {one-line summary of each, attributed}
...
```

Apply as **one commit**, then reply from **each** thread to the
same commit SHA so every reviewer sees the resolution. Resolve
all source threads. Merge logic only fires when the *concern* is
identical — two reviewers flagging the same line with different
asks (one wants a rename, one wants extraction) stay separate
suggestions.

### Split multi-issue comments into per-item suggestions

When a single reviewer comment contains multiple distinct sub-items
(numbered list, separate paragraphs) and each sub-item has a
different tradeoff (apply / skip / defer), split it into one
suggestion block per sub-item — not a single bundled prompt.

- Emit one `Comment {n}/{total}` consultation per sub-item in Step 5.
- Renumber `{total}` to reflect the post-split count.
- Merge sub-items only when the concern is identical and the
  decision applies uniformly. Shared parent comment is not a merge
  criterion.
- Failure mode: bundling forces a single `(a)/(e)/(d)/(s)` answer
  across items with different correct decisions, removing the
  user's ability to differentiate.

### Treat multi-reviewer convergence as an incomplete-fix signal

When two or more reviewers (any combination of bots and humans)
independently flag the **same class of concern** within a single
review cycle — even on different lines or files — treat it as
evidence that an earlier fix on that topic was incomplete, not
as a coincidence of two checkers running the same heuristic.

Trigger pattern: a category that was supposedly addressed in a
prior commit shows up again from multiple sources after the next
push. Common categories where this fires: credential exposure,
input validation, cross-doc consistency, naming/rename cleanup,
test enumeration drift, error-handling gaps.

When the trigger fires:

1. Do **not** triage the new comments as independent findings.
   Merge them into a single finding even when the lines or files
   differ — the *concern class* is what's shared.
2. Pause and re-ask: "Is the prior fix incomplete? What sibling
   instances of this class exist in the diff that the prior
   commit missed?"
3. Run the Step 6 issue-class scan **before** drafting any fix —
   grep the full PR diff for every path matching the concern
   class, including paths the new comments did not flag.
4. Apply the fix to **every** instance in one commit, then reply
   from each flagging thread referencing the same commit SHA.

This complements the same-line dedup above: same-line dedup
handles "different reviewers, same line, same concern"; the
convergence rule handles "different reviewers, different lines,
same concern class — and the prior fix on this topic missed
siblings." Both signals point at the same root remedy: scan the
class, fix the class, reply once.

## Step 5: Consult — Collect All Decisions First

**HARD RULE:** Do NOT touch code during this step. This is a
consultation-only phase. Present each `judgment-required` comment one
at a time, collect the user's decision, then move to the next. No
edits, no commits, no replies — just decisions.

### Partition before any prompts

**HARD RULE:** Before emitting **any** Step 5 output, walk every suggestion produced
in Step 4 and place each into exactly one of two lists:

```
obvious_fixes[]       # tag == "obvious-fix"
judgment_required[]   # tag == "judgment-required"
```

Re-read each suggestion's "Why this could be skipped" rationale during
the partition — not just the tag — and re-route any item whose
rationale concedes the comment is right (empty / "no valid reason" /
"no good reason to skip" / `—`) into `obvious_fixes[]` regardless of
its prior tag. The partition is the last opportunity to correct a
misclassification before the prompt loop starts.

The per-comment consultation loop iterates **only** over
`judgment_required[]`. The bulk-apply preview below covers
`obvious_fixes[]`. Never feed an `obvious-fix` item into the per-comment
loop — doing so forces the user to type `a` for ceremony on a finding
the agent already conceded was correct.

### Bulk-queue preview for obvious-fix comments

**HARD RULE:** Step 5 is execution-free. Obvious-fix items get **queued**
into `fixes_to_apply` during Step 5; they are not applied, committed,
or pushed until Step 6 runs the unified execution pass. The user
sees the full triage outcome — obvious + judgment-required — before
any code change lands.

Per-comment consultation is the default for `judgment-required`
items only. `obvious-fix` items — those whose skip rationale is
empty / "no valid reason" / equivalent (see Step 4 classification
rules) — go to the **bulk-queue preview**, not the per-comment
loop. They still need a single confirmation gate; they do not need
a per-item decision.

Acceptable opt-ins to extend bulk-queue across the **whole** set
(including any remaining `judgment-required` items):

- The user invoked the skill with an explicit auto / yes-to-all flag.
- The user, after seeing the bulk preview below, responds with an
  affirmative phrase (`auto`, `yes-to-all`, `apply all`).

If `obvious-fix` items exist, present a single preview block and ask
once before queueing:

> "**Bulk-queue candidates ({K} obvious fixes — skip rationale empty
> / no valid reason):**
>
> 1. {path}:{line} — {one-line summary}
> 2. ...
>
> I'll **queue** all {K} for Step 6 execution (one commit per
> finding; replies + thread resolution remain normal). Step 6 runs
> only after all judgment-required items below are triaged. Reply
> **stop** to switch any of these to per-comment consultation, or
> list the indices you want consulted (e.g., `consult 2,4`)."

Default on silence, affirmative, or unrelated reply: queue all
obvious-fix items into `fixes_to_apply` and proceed to the
per-comment loop for `judgment-required`. Only an explicit
`stop` / `consult <indices>` diverts items into the per-comment
loop. The single confirmation gate prevents silent execution while
honoring that obvious-fix items have no per-item decision to make.

When `judgment-required` items also exist, the per-comment loop
runs **after** the obvious-fix queueing — but **no execution
happens until Step 6**. The user sees every queued/accepted fix in
the "After all decisions collected" summary before any commit
lands.

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

**HARD RULE:** One comment per message — never batch. Emit exactly one
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

Announce the transition to execution. `fixes_to_apply` now contains
both bulk-queued obvious-fix items and judgment-required items the
user accepted via option `a`/`e`. Step 6 processes the unified list,
one commit per fix, in order:

> "All {total} comments reviewed. Decisions collected:
> - {obvious_count} obvious fixes queued (bulk-queue)
> - {apply_count} judgment-required fixes accepted (option `a`/`e`)
> - {followup_count} follow-up questions to post (non-reserved options)
> - {dismiss_count} dismissals (option `d`)
> - {defer_count} deferrals to follow-up tickets (option `t`)
> - {skip_count} skipped (option `s`)
>
> Moving to implementation — I'll apply all {obvious_count + apply_count}
> fixes now, one commit per fix, verifying each."

## Step 6: Execute — Apply Fixes, Verify, and Commit

**Now** apply all decisions collected in Step 5. Process each entry in
`fixes_to_apply` and `dismissals` in order.

### Issue-class scan before each fix

**HARD RULE:** Before applying any fix, identify the **class** of the underlying
issue (credential exposure, missing validation, unhandled error,
race condition, missing fallback, etc.) and grep the **full PR
diff** for every path that could share the same class. Apply the
fix to all matching paths in **one commit** rather than waiting
for the next review cycle to surface them.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" | grep -nE '<class-pattern>' \
  | grep -v '<already-fixed-pattern>'
```

Pattern hints by issue class:

| Class | Grep pattern (illustrative) |
|-------|-----------------------------|
| Credential / token in stderr | `git (clone\|fetch\|push)`, `curl`, `wget`, `>&2`, `2>&1` — minus already-redacted lines |
| Missing input validation | the validated symbol + every entry point that takes it |
| Unhandled exception | the exception type + every call site of the throwing function |
| Race condition / TOCTOU | the file/resource path + every read-then-write site |
| Missing retry / timeout | the call type (`requests.get`, `http.client`, etc.) |

Fold every matching path into the same commit. The reply comment
should list every path covered so the reviewer doesn't reconstruct
the surface: `Applied at <path>:<line>, <path>:<line>, …`. The
goal is **one commit per finding-class**, not one per finding.

This rule fires alongside the same-line dedup (Step 4) — same-line
dedup merges multiple comments **about the same line**; this scan
extends a fix to **the same class on different lines**.

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
   Fixed in [`<short>`](https://github.com/{owner}/{repo}/commit/{full_sha}) — {explanation}
   ```

   **HARD RULE:** Derive the full SHA from git, never extend the short
   SHA by inference. The 7-char short SHA is a prefix; the
   remaining 33 chars cannot be guessed. Capture the canonical
   full hash immediately after each commit:

   ```bash
   FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)
   ```

   Use `$FULL_SHA` in the URL and the 7-char short SHA in the
   link text. Fabricated full SHAs return 404/422 from the
   GitHub commit-URL renderer and force a delete-and-repost
   cycle; verify before embedding.

   This rule applies to **every** reply comment that references
   a commit, not only the first — if a single reply mentions
   multiple commits, link each one with its own verified full SHA.

Use the commit type that matches the nature of the change: `fix` for bug
fixes, `refactor` for restructuring, `feat` for new behavior. Always
include the emoji per `wk-commit` conventions.

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

### HARD RULE: Skip the confirmation gate when Step 5 decisions are explicit

Step 5's per-comment decisions (`a` / `e` / `d` / `t` / `s`) **are**
the explicit user confirmation required by Hard Rule 1. Re-asking
"proceed? (yes / edit / abort)" after a fully-decided Step 5 is
redundant ceremony — the user already authorized every action,
one comment at a time.

- **Default behavior:** print the resolution summary below, then
  proceed directly to Step 8 (adversarial-review gate → push →
  replies). Do **not** emit a "Proceed?" prompt.
- **Gate fires only when** one of these applies:
  - Any `(e)` edit in Step 5 where the user described an adjustment
    the agent did not echo back verbatim for confirmation (the
    adjusted approach was not reviewed by the user).
  - Co-author session where the PR author's name / email for the
    `Co-authored-by:` trailer was **inferred** rather than read
    directly from git log / PR metadata.
  - Step 5 contained any ambiguous batch where the agent collapsed
    multiple comments into one decision (should not happen given
    the one-per-message HARD RULE, but guard anyway).
- When the gate fires, emit the prompt below; otherwise announce
  "All decisions explicit — proceeding to adversarial-review gate
  and push" and continue.
- When the gate is skipped, Step 8.5 (Sync PR description) is the
  only remaining drift-catch — emit the `gh pr edit --body` call
  there unconditionally, even if the body looks current.

After ALL comments are processed, present a full summary:

```
## Resolution Summary

### Fixes applied ({count} commits)
1. {sha-1} — fix(feature): 🐛 invalidate session on logout
   - Addresses: @{reviewer-a} src/feature.ts:42, src/feature.ts:58

2. {sha-2} — refactor(service): ♻️ extract timeout config
   - Addresses: @{reviewer-b} src/service.ts:33

### Bot reviews addressed ({count})
3. src/feature.ts:15 — {review-bot}[bot]: applied suggested null check
4. src/service.ts:22 — {review-bot}[bot]: dismissed (false positive)

### Reply comments to post ({count})
1. src/feature.ts:42 → "Fixed in [`{sha-1}`](https://github.com/{owner}/{repo}/commit/{full_sha}) — session now invalidated on logout"
2. src/service.ts:33 → "Extracted to config — timeout is now configurable"
3. src/feature.ts:15 → "Applied — added null check as suggested"
4. src/service.ts:22 → "False positive — value is guaranteed non-null by L18"

### Follow-up questions ({count})
5. src/utils.ts:18 → "Could you clarify whether you mean..."

### Threads to resolve ({count})
- src/feature.ts:42, src/feature.ts:58, src/service.ts:33, src/feature.ts:15, src/service.ts:22

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

Ask **only when the gate above fires**:
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

When the gate fires, wait for explicit confirmation. If "edit," ask
what to change. If "abort," stop without pushing or posting anything.
When the gate does not fire, proceed straight to Step 8.

## Step 8: Push and Respond

**Only after explicit user confirmation.**

### Adversarial-review gate (run before `git push`)

Invoke `wk-adversarial-review` against the new commits introduced in
this session (`$BASE...HEAD`). Push is **conditional** on a `clear`
verdict (or `suggestions-only` with the user's accepted A/B/C choice).
On `blocked`, address each blocker with a fresh atomic `wk-commit`,
re-invoke the skill, and loop until clear. Never push past a blocker —
that is the failure mode this gate exists to prevent.

### Post-rewrite divergence guard (run before `git push`)

Any history-rewriting operation performed **during** this session —
`git commit --amend`, a fixup commit + `git rebase --autosquash`, an
interactive rebase — invalidates the Step 2 reconcile, which ran
*before* the rewrite. The rewritten local branch can now be both ahead
of and behind the remote PR branch. Re-check divergence before pushing:

```bash
HEAD_BRANCH=$(gh pr view --json headRefName --jq .headRefName)
git fetch origin "$HEAD_BRANCH" --quiet
COUNTS=$(git rev-list --left-right --count "HEAD...origin/$HEAD_BRANCH")
AHEAD=$(echo "$COUNTS" | cut -f1)
BEHIND=$(echo "$COUNTS" | cut -f2)
```

- `BEHIND == 0` → fast-forward push is safe; proceed to **Push commits**.
- `AHEAD > 0` **and** `BEHIND > 0` → diverged: the rewrite dropped
  remote commits the local branch no longer contains. Do **not**
  force-push (Hard Rule 4) and do **not** blindly rebase — recover by
  cherry-picking the remote-only commits onto the rewritten local tip,
  then re-check until `BEHIND == 0`:

  ```bash
  git cherry-pick $(git rev-list --reverse "HEAD..origin/$HEAD_BRANCH")
  ```

- If the cherry-pick conflicts, or the remote-only commits are
  themselves rewritten versions of the same local changes (same diff,
  different SHA), stop and surface to the user — do not guess.

### Push commits

```bash
git push
```

If push is rejected as non-fast-forward, the remote PR branch moved
during this session. When no history was rewritten this session,
re-run the Step 2 reconcile (`git fetch origin` then
`git rebase origin/{head_branch}`) and push again. When history **was**
rewritten this session, use the Post-rewrite divergence guard's
cherry-pick recovery instead of rebasing — rebasing rewritten local
history onto the remote duplicates or drops commits. Never force-push.
If the rejection is for any other reason, tell the user and ask how to
proceed.

## Step 8.5: Sync PR description (mandatory, immediately after push)

**HARD RULE:** Emit `gh pr edit {number} --body ...` after **every**
`git push` in this skill, **before** posting any reply comments or
resolving threads. The body-sync is non-negotiable even when the body
looks "roughly correct." When the Step 7 confirmation gate is skipped
(per "Skip the confirmation gate when Step 5 decisions are explicit"),
this step is the **only** drift-catch checkpoint — emit the edit even
if you believe the body is current.

Resolve sessions invalidate prior claims in the body: commit counts,
file lists, "remaining work" sections, linked commits, and **the CI
status section** (a now-green branch needs the section updated
explicitly; a re-running branch needs the status reflected). Skipping
the sync misleads reviewers and future readers.

The agent must explicitly satisfy this step with one of:

- A `gh pr edit {number} --body "..."` call that overwrites the body
  with the synced content.
- An explicit "no drift detected" log line: a one-line statement that
  the agent compared the current body against {commit list,
  test-plan items, CI section, linked SHAs} and confirmed each is
  current. The log is required — silently skipping is the failure
  mode.

**HARD RULE:** Before overwriting the PR description, preserve metadata
lines — see `skills/pr/references/pr-description-metadata.md`.

```bash
gh pr edit {number} --body "$(cat <<'EOF'
{updated description with metadata preserved}
EOF
)"
```

Items to verify in the body before deciding "no drift":

- Commit list / commit count — each new SHA from this session linked
  as `[`abc1234`](https://github.com/{owner}/{repo}/commit/{full_sha})`.
- Test-plan checkboxes — check off items now satisfied by green CI or
  this session's fixes.
- CI status section — reflect the current run's terminal state when
  one exists; remove stale "pending" claims.
- "Remaining work" / "Known limitations" — drop items addressed in
  this session's commits.
- File lists — add any files touched in this session's fixes.

This mirrors the `wk-pr` rule: after every push to a branch with an
existing PR, the description must be updated.

## Step 8.6: Post replies, reactions, and resolve threads

Once Step 8.5's body-sync is satisfied, proceed with reply posting,
emoji reactions, and thread resolution. Each subsection below is part
of the reply-posting workflow.

### Causes of 404 on reply posting

`POST /pulls/{n}/comments/{id}/replies` can return **404** even when the thread still exists. Three key facts:

- **Force-push** (e.g., rebase in Step 2) invalidates existing REST review comment IDs.
- **Bot review replacement** — bots that recreate their entire review object on each push destroy previous REST comment IDs; the GraphQL thread node ID (`PRRT_...`) survives.
- **REST comment IDs are unstable; GraphQL thread node IDs are stable.** A 404 reply is expected and non-fatal — log it, attempt thread resolution via GraphQL node ID, and continue.

### Refresh thread IDs when bot reviewers are present

Before posting any replies when the comment map contains bot reviewers:

- Re-run the GraphQL `reviewThreads` query (Step 3 form) against the post-push HEAD; the push commonly triggers an immediate re-review that expires all pre-push REST IDs.
- Rebuild the thread/comment ID map for every bot reviewer's findings using the fresh query results.
- Match each pre-push finding to its post-push thread by stable identity tuple `(path, line, root_comment.body_excerpt)` — REST IDs are unstable but this tuple survives review replacement.
- If the post-push fetch shows a finding was dropped (bot retracted it), skip the reply and continue.
- The 404-recovery fallback below still applies to any reply that fails after this refresh.

### Detect in-place updates to bot summary issue comments

Some bots track PR state through a single persistent issue comment
keyed on a magic HTML marker (e.g., `<!-- <bot-id>-review -->`) and
overwrite its body on each cycle rather than posting a new comment.
Diff-based "new comment since pre-push" detection misses the update.

- For every bot-authored issue comment captured in the pre-push
  snapshot, re-fetch its body via `gh api .../issues/comments/{id}`
  and compare against the snapshot.
- A body transition from "Found N issues" / active-findings shape to
  a clean shape ("No issues found", empty list) is a positive
  resolution signal — log it in the session summary and resolve any
  related inline threads.
- A body transition that adds new findings is a regression — route
  the new finding through Step 4 like any other active comment.

### Re-check pending self-review before replies

**HARD RULE:** Re-run the Step 3 pending-review check immediately before posting
the first reply — even if Step 3 found none.

- A pending self-review submitted between Step 3 and Step 8 (manual review pass,
  another agent, IDE auto-draft) will reject every reply with HTTP 422
  (`user_id can only have one pending review per pull request`).
- Run the same `gh api .../reviews | jq` query from "Pre-check: pending
  self-reviews" against the current state.
- If a pending review now exists, submit it as `COMMENT` (same `event=COMMENT`
  call as Step 3) before posting any reply. Do not ask the user again — the
  Step 3 prompt already authorized the resolution path for this session.
- Reject any reply loop entry whose pre-flight skipped this re-check.

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

### Add emoji reaction after each reply

Immediately after a reply posts successfully, add an emoji reaction
to the **original comment** (the root of the thread) to signal the
outcome. Reaction selection by triage outcome:

| Triage | Reaction content | Emoji |
|--------|-----------------|-------|
| `a` (fix applied) or `e` (edit) | `+1` | 👍 |
| `d` (dismiss — not useful) | `-1` | 👎 |
| `f` (follow-up question from author — good question) | `heart` | ❤️ |
| `t` (defer to ticket — acknowledged) | `+1` | 👍 |
| `s` (skip) or `r` (rethink) | — | no reaction |

Route by comment surface:

**`surface: inline`** (review comment):

```bash
gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions \
  --method POST -f content="{reaction}"
```

**`surface: conversation`** or **`surface: review_body`** (issue comment):

```bash
gh api repos/{owner}/{repo}/issues/comments/{comment_id}/reactions \
  --method POST -f content="{reaction}"
```

Reactions are fire-and-forget — a non-200 response is logged and
skipped; never block or retry on a failed reaction. A duplicate
reaction returns HTTP 200 with the existing reaction object; treat
it as success.

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

If the mutation returns **`NOT_FOUND`** (or `Could not resolve to a node` / similar), recover in four steps (cap one retry per thread):

1. Re-run the GraphQL `reviewThreads` query (Step 3 form) for fresh IDs.
2. Look up the original thread by stable identity `(path, line, root_comment.databaseId)`.
3. If matched, retry `resolveReviewThread` with the new thread ID.
4. If no match (bot dropped the finding) or retry fails, log and continue.

If resolution returns any other error, log and continue.

### Re-surfaced findings on the post-push review

- A post-push bot re-review commonly re-reports findings **already addressed in this session** — they are echoes, not new issues (the bot re-runs before its database catches up).
- When Step 4 sees a comment matching `(path, line, concern)` of a thread already resolved in this session, tag it `already-addressed`, reply `"Already addressed in commit {short-SHA} earlier in this session. Resolving thread."`, and resolve without re-prompting or committing.
- The session-local resolution map is the ground truth; do not triage `already-addressed` echoes as `dismiss` (mislabels a valid finding) or re-apply the fix (produces an empty commit).

**HARD RULE:** Never resolve threads in the `reply_only` list. Those have
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

## Step 9.4: Capture Adversarial-Review Learnings (mandatory)

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class
surfaced this session **before** entering the Step 9.5 CI wait. Every
reviewer- or bot-flagged finding is by definition a coverage gap in
`wk-adversarial-review`'s pre-flight sweeps; the next `wk-sharpen` batch
absorbs the learnings.

- Run **immediately after Step 9 (push complete + conflict check)** and
  **before Step 9.5 (CI wait)**. CI wait blocks foreground work — any
  task scheduled after it is dead time. Emit learnings while CI is
  still pending; do not park them behind a background watch.
- Do not skip when the session was short, routine, or resolved zero
  findings — even a zero-finding session is a signal that the
  pre-flight baseline is holding for that PR class. Log it.

### What to capture

For each comment processed in this session (excluding self-review and
already-addressed echoes), classify the underlying issue and group:

- **Vulnerability-class drift** — fix applied to one site, sibling not
  fixed; same class on parallel paths.
- **Stale comment / doc drift** — code comment, PR body, or spec out
  of sync with the changed code.
- **Dead defensive guard** — guard added against a sentinel an upstream
  transform already eliminates.
- **Hardcoded base / branch / version pin** — literal default branch
  name, `:latest`, unpinned dep.
- **Cross-doc enumeration miss** — test count, flag list, error code
  catalog out of sync with the code.
- **Design-pivot doc drift** — spec/plan/ADR still describes pre-pivot
  shape after a structural change.
- **Signature widening miss** — caller updated but a sibling caller or
  initializer was not.
- **Raw-API bypass** — review comment posted outside the pending-review
  flow.
- **External-call shape change without local reproduction.**
- **Comment-accuracy drift** — `always`, `guaranteed`, `never` claims
  contradict current code.
- **Other** — any reviewer-caught issue that does not map to an
  existing category. Capture the class name as a new candidate.

### Emit one learning per issue class

For each non-empty category, invoke `wk-learn` targeting
`wk-adversarial-review`:

```
Skill(wk-learn, args="adversarial-review")
```

The learning body must encode:

- **Class:** which category from the list above (or a new one).
- **Mechanism:** what the reviewer saw that the pre-flight should have
  caught — described as a generic pattern, never with file paths,
  line numbers, reviewer logins, or commit SHAs from this PR.
- **Detection sketch:** a one-line grep, command, or check that
  adversarial-review's Step 2 mechanical sweeps could run to catch the
  next instance. If the existing sweep covers the class but missed it,
  note the false-negative cause instead.
- **Confidence:** `high` (mechanical detection possible) or
  `judgment` (requires subagent reasoning).

### Skip conditions

- The session resolved zero findings AND no reviewer/bot threads were
  active — emit one summary learning ("baseline holding") rather than
  skipping entirely.
- The finding originated from the agent's own self-review thread —
  self-review is excluded from this capture (its learnings route to
  `wk-self-review`, not `wk-adversarial-review`).

### Post-CI loop addendum

If Step 9.5's post-CI fetch surfaces genuinely-new findings, re-run
this step (Step 9.4) for that batch **before** the next CI wait. Each
CI cycle emits its own learning set; do not defer multi-cycle
learnings to the end of the session.

## Step 9.5: Wait for CI, Then Loop on New Comments

A push at Step 8 triggers a fresh CI run and often a fresh review pass
from any review-automation that re-fires on new HEAD. Declaring
resolution complete before CI reaches a terminal state leaves
post-push findings (CI failures, late-arriving bot comments,
description-drift callouts) for the next manual invocation. The agent
already has the context to address them in this run.

### Poll CI to terminal state

Delegate CI status polling to `wk-buildkite` (or the platform skill
matching the repo's CI). Wait until the build reaches a terminal
state — `passed`, `failed`, or `canceled`.

```
Skill(wk-buildkite, args="<head_sha>")
```

If CI **failed** or was **canceled**, surface the failure and exit:

> "CI on {short-SHA} did not pass ({state}). Failing job: {url}.
> Fixing CI takes priority over remaining review feedback — re-run
> `wk-pr-resolve` after CI is green."

CI fixes outrank further comment triage on the same branch — a
broken build invalidates fresh review feedback anyway.

### Re-fetch comments after CI passes

When CI passes, re-run **Step 3** (all three surfaces) against the
post-push HEAD. Late-arriving findings appear here:

- review-automation re-runs that fire after CI succeeds
- description-drift bots that compare body to HEAD
- humans who reviewed the freshly-pushed commits

Compare the new comment map to the session-local resolution map
maintained across this run. Any active comment whose `(path, line,
concern)` matches a thread already resolved earlier in this session
is an `already-addressed` echo — handle per the existing rule in
Step 8 ("Re-surfaced findings on the post-push review").

### Loop back if genuinely new findings exist

If the post-CI fetch surfaces unresolved comments that are **not**
already-addressed echoes:

1. Re-enter Step 4 (Generate Suggestions) for the new findings.
2. Re-enter Step 5 (Consult) — the partition rule above applies
   again; new `obvious-fix` items go to bulk-apply, new
   `judgment-required` items to per-comment consultation.
3. Re-enter Steps 6–9 for the second cycle.
4. Re-enter Step 9.5 again after the second push.

Exit the loop only when CI passes **and** the post-CI fetch surfaces
no new genuinely-unresolved comments. Cap at three iterations per
session — beyond that, surface to the user that the PR is in a
review-thrash loop and ask how to proceed.

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

Invoke `wk-retro` to capture session-level learnings. This is
mandatory — do not skip even if the session was short or routine.
Adversarial-review learnings were already emitted in Step 9.4
(before CI wait); this step covers session-level reflection only.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "resolve PR comments" | Full workflow |
| "address review feedback" | Full workflow |
| "fix the comment" / "there's a description issue" (open PR on branch) | Auto-activate; treat the open PR as the target instead of asking |
| "fix PR #{number}" | Full workflow for specific PR |
| "respond to reviewers" | Full workflow with focus on replies |
| Session ends | Capture adversarial-review learnings (Step 9.4, pre-CI-wait), then `wk-retro` (Step 11) |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running verification commands
- Commit signing configured (GPG or SSH)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-resolve`).
