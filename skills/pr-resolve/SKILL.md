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
  version: '2026.06.23-220111'
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
manage the full resolution cycle from sync to summary. Verbatim command blocks
and the suggestion-format template live in
[`references/commands.md`](references/commands.md); use them exactly.

## Resume After Compaction

Resumed from a compaction summary mid-skill → read the last completed step,
confirm the resume point (default: next uncompleted step), skip completed steps,
re-run possibly-stale sync/fetch (Steps 2–3). Never restart from Step 1; never
drop tail steps absent from the summary (Step 9.4 learnings, 9.5 CI wait +
new-comment loop, Step 11 retro).

## Hard Rules

0. **Scope GitHub payloads through `wk-gh`.** Satisfy its org-scope gates before
   any GitHub read/write; `gh api` is the only transport. Append the canonical
   outbound footer to every reply, PR-body edit, and thread message at render time.
1. **Never push without explicit user confirmation.**
2. **Never post reply comments without explicit user confirmation.**
   - **HARD RULE — route every outbound reply/dismissal body through
     `Skill(wk-tone)` before drafting or posting.** Prose posted as the user;
     filter banned register before payload render.
3. **Only resolve threads you actually worked on** — after a fix, explicit
   dismissal, or tracked deferral. Never resolve follow-up questions, skipped,
   rethink-pending, or ordinary self-review threads.
4. **Never force-push** — regular `git push` only. *Exception:* a base-advance
   rebase (Step 2) may `git push --force-with-lease`; never bare `git push -f`.
5. **Never commit without attempting verification.** Verification unavailable or
   failing → inform the user before proceeding.
6. **Commits follow `wk-commit` conventions** — conventional format with emoji,
   signed commits, HEREDOC messages. Never `--no-gpg-sign`.
7. **One commit per triage unit** (final Step 4 suggestion after merge/split).
   Do not bundle separate reviewer comments unless Step 4 merged them. Push once
   after all commits exist.
8. **Exclude self-review comments.** Do not triage, reply to, fix, or resolve
   threads whose root comment was authored by the PR author or current user.
   - **Resolve submitted self-review threads only at merge readiness** — branch
     protection can count every unresolved thread regardless of authorship.
   - **Surface external replies inside self-review threads** in the summary; do
     not triage or resolve them.
   - **User-touched reviewer threads allow one narrow follow-up** — on a
     reviewer/bot thread the user already replied to, post one follow-up only when
     the session changed the finding or a new item needs callout. Still requires
     Hard Rule 2.
9. **Co-author attribution.** Current user not the PR author → add a
   `Co-authored-by:` trailer for the PR author on every commit. Real identities
   only; never invent agent co-authors.
10. **Include bot reviews** as first-class feedback. Evaluate each for
    correctness before accepting or dismissing.
11. **Adversarial-review gate before push** — new commits this session must pass
    `wk-adversarial-review` before `git push` (mechanics in Step 8).
12. **Implement handoff documents before deleting them.** A branch file whose
    name signals remaining work → read it fully, implement its items, delete it in
    the same commit as the last change. Plan first if the work is large or spans
    repos.

## Step 1: Identify the PR

Run `gh pr view --json ...` (commands.md §1). No PR detected → ask for
number/URL. Extract `{owner}`, `{repo}`, `{number}`, `{base_branch}`,
`{head_sha}`.

Detect co-author scenario: capture `$PR_AUTHOR` and `$CURRENT_USER`
(commands.md §1). `$PR_AUTHOR != $CURRENT_USER` → co-author session: record both
logins, treat both as self for comment exclusion, give the PR author
`Co-authored-by:` on every commit.

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

Co-author session adds:
> "Note: PR authored by @{pr_author}. Commits will include co-author attribution.
> Comments from both you and @{pr_author} are excluded from triage."

## Step 2: Sync Branch

Sync with both base and remote PR branch before triaging. Commands: commands.md §2.

- **HARD RULE — conflict-marker pre-flight is the first action.** Before any
  fetch or comment read, run `git diff --check`. Any conflict markers → resolve
  (or delegate to `wk-pr-update`) to a clean tree before fetching one comment.
  Never triage or fix on a conflicted tree — it embeds markers in commits or
  generates suggestions against a stale diff.
- **Reconcile remote PR branch first** — fetch, rebase onto `origin/$HEAD_BRANCH`
  if remote is ahead. Keeps next push fast-forward; avoids a divergent second
  merge commit.
- **Integrate the base branch** — merge-aware pre-check: HEAD already contains a
  base merge and `$BEHIND <= 5` → plain `git merge`.
- Otherwise delegate base integration to `wk-pr-update` (only if it preserves the
  no-force-push contract); on an unresolvable conflict, validation regression, or
  required forced push it reports → stop and surface the blocker.
- **Base-advance conflict (upstream PR merged) → rebase onto the new base to
  resolve.** Base moved → the new base is authoritative; replay the branch onto
  it, resolving each conflict against the base:
  ```bash
  git fetch origin "$BASE_BRANCH"
  git rebase --onto "origin/$BASE_BRANCH" "$(git merge-base HEAD "origin/$BASE_BRANCH")"
  ```
  Re-verify, resume only on a clean tree, push with `git push --force-with-lease`
  (Hard Rule 4 exception) — never bare `-f`.
- **HARD RULE — audit dropped safety guards after each conflict resolution.** The
  base side (HEAD during rebase) is canonical `origin/$BASE_BRANCH`; a guard there
  was intentional. Diff both sides for signal/context/cleanup primitives
  (`signal.Stop`, `context.Cancel*`, `sync.*`, `defer`, `close(`, `os.RemoveAll`,
  resource releases); any on the base side but absent from the result is a dropped
  guard — restore it unless the incoming commit removed it with rationale. Green
  compile/tests do **not** prove it unneeded; block until each absence is confirmed.
- **Stage resolved files from the repo root.** Session cwd may be a subdirectory,
  where `git add <repo-relative-path>` exits 128. Use
  `git -C "$(git rev-parse --show-toplevel)" add <paths>` for all staging here and
  in Step 6.
- **HARD RULE — Step 2 is unconditional.** Run fetch + ahead/behind before
  triaging any comment, whatever the branch state. "Already up to date" is an
  outcome of running it, not a reason to skip. Step 9's test-merge is a conflict
  check, not a sync substitute — a skipped Step 2 is a violation even when Step 9
  clears clean.

## Step 3: Fetch Unresolved Comments

Fetch all three feedback surfaces every run (build the comment map via
commands.md §3 — GraphQL for unresolved threads, REST for full details):

| Surface | Endpoint | Holds |
|---|---|---|
| Inline review comments | `/pulls/{n}/comments` | Line-attached feedback |
| Review summary bodies | `/pulls/{n}/reviews` | Overall review text |
| PR conversation comments | `/issues/{n}/comments` | Top-of-PR discussion, bot summaries |

Map fields: `threadId`, `commentId`, `path`, `line`, `body`, `user`, `userType`,
`replies[]`, `isOutdated`, `isResolved`.

- **Read bot inline-comment bodies via GraphQL `reviewThreads` → `comments.nodes[0].body`, not REST `GET /pulls/{n}/comments/{id}`.** After a bot replaces its review, the REST `databaseId` 404s for *all* ops (even a read GET); the thread node ID is stable.

**Three-surface pre-flight check:**

- Track per-invocation flags (`inline_comments_fetched`, `review_bodies_fetched`,
  `issue_comments_fetched`); cached results from a prior invocation do not count.
- Any flag false → stop and report the failed surface; never advance on partial fetches.

**Agent-observed drift is first-class feedback.** PR metadata/diff/docs drift
seen during Steps 1–3 → inject into the comment map as `surface:
agent_observation` (`bot_badge` flag); triage like any finding.

**Classify comment authors:**

| `user_type` | Pattern | Classification |
|---|---|---|
| `Bot` | Any bot suffix or custom bot login | Bot review |
| `User` | Matches PR author login | Self-review |
| `User` | Matches current user login in co-author session | Self-review |
| `User` | Any other login | Reviewer |

**Pre-check pending self-reviews.** A pending review blocks reply posting with
HTTP 422. Capture `$PENDING_REVIEW_ID` (commands.md §3); one exists → ask the
user to submit it as `COMMENT` or abort, then submit before any reply.

**Filter and group:**

- Active = thread unresolved, not self-review, not truly outdated.
- Outdated thread, concern gone → record auto-skipped and resolve. Unresolved outdated → still open feedback.
- Sort active comments by file path then line; separate bot from human in the summary.
- Report skipped self-review threads and external replies hidden inside them.

## Step 4: Generate Suggestions

**Bot / non-convergence handling:**

- Track bot thrash by `(path_prefix, concern_class)` and total active findings per round.
- Stop and ask before another fix when: same pair re-fires 3×; totals stop falling for 2 consecutive rounds; or a new finding contradicts an accepted fix.
- Bot reply: documented command syntax if available, else a generic reply tagging the bot and stating the decision.
- **Surface prior-round dismissals.** Before a judgment-required finding, check
  the session `dismissed` list and prior-round notes for the same field/concern
  class — a bot re-firing on a dismissed field from a new angle ("redundant" vs
  "unused") is the same decision. Found → surface the prior reason inline, default
  to `(d)`, ask once.

**All-Minor bulk-dismiss gate.** Every active finding Minor and each has a
plausible skip rationale → offer one bulk action before per-item triage:

> "All {N} findings are Minor. Bulk dismiss all, or triage individually?
> (a) dismiss all  (b) triage individually"

Enter per-item triage only when ≥1 finding is Major/Critical or any finding
lacks a plausible skip rationale.

**Order of processing — HARD RULE: triage every comment before applying any
fix.** Classify the whole set first, then apply accepted fixes as one batched
pass — never loop comment-by-comment through fix/commit/push.

- Process bot reviews first, then human comments.
- For each: read full file context, the comment, and the reply chain before generating a fix.

**Org-specific policy questions.** Reviewer question touches org policy → search
the configured KB first and cite an authoritative doc; fall back to general
knowledge only if the KB is empty, flagging the fallback. Skip for code-level
intent, design rationale, or test-coverage questions.

**Missing-documentation findings.** Before surfacing a bot finding that
behavior/rationale/trade-off is undocumented, grep the diff, touched files, and
repo docs; covered (or code makes it unambiguous) → cite the reference and
dismiss; else present normally.

**Suggestion format** — see commands.md §4. Every suggestion includes reasoning
for applying and discarding (`Why this fix` / `Why skip`); `{bot_badge}` is
`🤖 (bot)` for bots, omitted otherwise. Be honest in the skip rationale; if no
good skip reason exists, say so.

**Detect design flaws.** Before drafting a localized patch, decide whether the
comment signals a design flaw (triggers: "this might not trigger", "depends on
X", "what happens if {edge case}", "why do we need this at all", "duplicated
with", "contract is unclear"). Fired → present the design change first, a
clarifying reply second; in Step 5 `(a)` applies the design option unless edited.

**Classify suggestions** — tag each `obvious-fix` or `judgment-required`:

| Tag | Condition |
|---|---|
| `obvious-fix` | Skip rationale empty, "no valid reason", "no good reason to skip", `—`, or otherwise concedes the comment is right. |
| `judgment-required` | A real tradeoff, false-positive possibility, scope question, multiple valid approaches, or security/performance judgment exists. |

Default to `judgment-required` when uncertain. Immediately before any Step 5
consultation prompt, re-read the skip rationale; it concedes the comment is right
→ re-tag `obvious-fix` and route to bulk-apply. Severity does not bypass this.

**Merge, split, convergence:**

- Merge duplicate comments on the same `path:line` with the same concern.
- Split one comment with multiple distinct sub-items into one suggestion each.
- Multi-reviewer convergence on the same concern class = incomplete prior fix:
  merge the class, fix it via the Step 6 issue-class scan, reply from each
  flagging thread.

## Step 5: Consult — Collect All Decisions First

**HARD RULE:** Consultation-only. Do not read files for editing, write code,
commit, push, or post replies.

**Partition before any prompts.** Place every suggestion into exactly one list:
`obvious_fixes[]` (tag == `obvious-fix`) or `judgment_required[]`. Re-read each
skip rationale during partition; rationale concedes the comment is right →
re-route into `obvious_fixes[]`.

**Bulk-queue preview for obvious fixes.** Obvious-fix items exist → present the
bulk-queue preview (commands.md §5) once before queueing. Default
(silence/affirmative/unrelated): queue all obvious-fix items into `fixes_to_apply`
and proceed. Only explicit `stop` or `consult <indices>` diverts.

**Present one judgment-required comment at a time.** For each, present the full §4
suggestion format then the per-comment prompt (commands.md §5). `a`, `e`, `d`,
`t`, `s`, `r` are reserved; extra options use other letters and must not redefine
them. Wait for the response before the next comment.

**HARD RULE — pre-emit count gate (mechanical).** Before sending a Step 5
message, count its `Comment {n}` decision headers; > 1 → hard-stop and split, one
message per comment. Fires even when items feel similar or the flow is already
"listing"; a batched prompt lets the user reply `a a d` — forbidden. The
intention-based rule above kept failing here, so the count check is its
structural guard.

**Decision handling** — record exactly one outcome per decision; `a`/`e`/`d`/`t`
all mark `resolve_after_push`:

- `a` Apply — record in `fixes_to_apply` `{path, line, description, code_change, threadId, commentId}`; draft "Fixed — {brief explanation}".
- `e` Edit — ask how to adjust; record the refinement in `fixes_to_apply`; draft the adjusted reply.
- `d` Dismiss — reuse the Step 4 `Why skip` rationale as the reason; do not re-ask. Ask only when it is empty / "No valid reason to skip", or to edit it. Draft "Dismissed — {reason}".
- `t` Defer — ask for the ticket URL/key; record in `deferrals` `{path, line, ticket_url, ticket_key, threadId, commentId}`; draft "Tracked in [{ticket_key}]({ticket_url}) — will address in a follow-up.".
- `s` Skip — record in `skipped`; leave the thread open and untouched.
- `r` Rethink — re-read the comment, surrounding code, and referenced context; produce deeper analysis with alternatives/risks; re-present the same comment with the same reserved options.

**After all decisions collected**, report the counts per bucket (obvious queued,
accepted, follow-ups, dismissals, deferrals, skipped), then: "Moving to
implementation — applying all accepted fixes now, one commit per triage unit,
verifying each."

## Step 6: Execute — Apply Fixes, Verify, Commit

Apply all Step 5 decisions: process `fixes_to_apply`, `dismissals`, `deferrals`
in order. Commands: commands.md §6.

**Issue-class scan before each fix.** Identify the issue class; grep the full PR
diff for sibling paths sharing it (commands.md §6). Include siblings in the same
commit only when they share the triage unit or were merged by Step 4. Per class:
credential/token leaks → grep shell commands and stderr redirections, minus
already-redacted lines; validation/exception/retry gaps → grep the affected
symbol plus every entry/call site; race/TOCTOU → grep the resource path plus
every read-then-write site; value/message/constant reporting → grep the **whole
changed file** (not just the diff) for the same shape (`grep "timed out after %v"
<file>`); a refactor clones the defect onto a sibling line.

**For each fix:**

1. Apply the change with Edit.
2. Verify with the repo's build/lint/test command. No build system → warn once. Verification fails → ask whether to fix, commit anyway, or skip. Go file → also run `goimports -local <module> -l <file>` before staging (`-w` fixes); `go test` misses import-grouping the CI format gate rejects.
3. Commit one commit per triage unit (HEREDOC template, commands.md §6; co-author trailer per Hard Rule 9).
4. Record the full SHA immediately: `FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)`.
5. Update the drafted reply with a clickable commit link, full SHA from git (never infer from a short SHA; format in commands.md §6).

**For each dismissal or deferral.** No code change — use the Step 5 reply.
Deferrals reference the user-provided ticket; never create tickets here.

**Do NOT push after each commit.** Push all commits together in Step 8.

## Step 7: Confirm Everything

**Skip redundant confirmation when decisions are explicit.** Step 5 decisions
(`a`, `e`, `d`, `t`, `s`) are explicit confirmation — do not re-ask "proceed?"
after a fully decided Step 5. The gate fires only when:

- an `(e)` edit was not echoed back verbatim;
- a co-author session inferred the PR author's name/email instead of reading it from git log / PR metadata; or
- an ambiguous batch slipped into Step 5.

When it fires:

> "Does this look correct? I will push {N} commits, post {M} threaded replies to
> individual review comments, resolve {R} threads, and leave {L} threads open for
> follow-up. Proceed? (yes / edit / abort)"

**Resolution rule.** Per Hard Rule 3: resolve only threads in
`resolve_after_push`. Submitted self-review threads resolve only at merge
readiness.

**Disambiguate "review" objections.** "don't post the self-review" / "skip the
review" → ask whether they mean a formal PR Review submission or the threaded
replies; default to the former unless they confirm the latter.

## Step 8: Push and Respond

Commands: commands.md §8.

**Adversarial-review gate.** Run `wk-adversarial-review` against the new commits
before `git push`. Push is conditional on a `clear` verdict or accepted
`suggestions-only` A/B/C choice. On `blocked`, address each blocker with a fresh
atomic commit, re-invoke, loop until clear.

**Post-rewrite divergence guard.** History rewritten this session → re-check
divergence before pushing (compute `$AHEAD`/`$BEHIND`, commands.md §8): `BEHIND ==
0` → safe; both > 0 → cherry-pick remote-only commits onto the rewritten tip,
re-check; cherry-pick conflicts or remote-only rewritten duplicates → stop and
surface.

**Push** (`git push`). Rejected non-fast-forward: no rewrite → re-run
reconciliation; Step 2 base-advance rebase → `--force-with-lease` (Hard Rule 4),
reconciling remote-only commits first on a rejected lease; any other rewrite →
the divergence-guard cherry-pick above. Never bare `git push -f`.

**Sync PR description immediately after push — HARD RULE:** Update the PR body
before posting replies or resolving threads, even when it looks current.

- Preserve metadata lines.
- Verify commit links, test-plan checkboxes, CI status, remaining work, known limitations, and file lists before deciding no drift.
- No drift → log an explicit "no drift detected" line naming the compared fields.
- **Never assert a result the agent cannot confirm.** Gate Testing/Results on known evidence (diff, CI output, user statement); no evidence → honest placeholder (`Pending — <how to exercise>`), never a template "build completed successfully".

**Re-check self-review and docs drift (every push):**

- Re-read agent-posted self-review comments; if a fix changed the code a comment describes, correct or resolve it.
- Invoke `wk-docs` against files touched this session; update docs/specs/README when behavior, signatures, or config changed.

**Post replies, reactions, resolve threads.** Re-run the pending self-review
check before the first reply; submit any pending review as `COMMENT` first. Post
replies sequentially, routed by surface (commands.md §8):

- Prefix issue-comment replies with a quote of the original comment.
- Multiple suggestions split from one issue comment (Step 4) → post **one
  combined reply** (you cannot reply to sub-sections of an issue comment).
- React on the original: `+1` for `a`/`e`/`t`; `-1` for `d`; `heart` for follow-up questions; none for `s`/`r`. Reaction failures are fire-and-forget.
- Before bot replies, refresh bot thread IDs: re-run the GraphQL reviewThreads query against post-push HEAD, match by `(path, line, root_comment.body_excerpt)`; skip replies for dropped findings.
- Resolve via GraphQL `resolveReviewThread` (commands.md §8); `NOT_FOUND` → refresh IDs once, match by stable identity, retry; no match/retry fails → log and continue. REST comment IDs die on force-push/bot replacement (GraphQL thread IDs are stable), so an inline-reply 404 → log and keep the thread in `resolve_after_push`. **Fully outdated thread (`line: null`)** → skip the REST reply (every REST op 404s, incl. GET); post one top-level `gh pr comment` summarizing the fixes instead.
- Detect in-place bot summary updates by re-fetching each captured bot issue comment: active→clean = positive resolution; added findings = regression → re-enter Step 4.
- Post-push comments matching `(path, line, concern)` from this session are already-addressed echoes: reply with the commit link, resolve, do not re-prompt or re-commit.

## Step 9: Check Merge Conflicts

Test-merge `origin/{base_branch}` with `--no-commit --no-ff` (commands.md §9).
Clean → abort the test merge and report success. Conflicts detected → abort and
ask whether to resolve them now.

## Step 9.4: Capture Adversarial-Review Learnings

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class surfaced
before the CI wait — never skip for short/routine sessions. Zero findings → one
baseline-holding learning.

Classify processed comments into generic issue classes (security, validation,
exception handling, race/TOCTOU, retry/timeout, defensive/dead guard,
API/external-call shape, docs/comment-accuracy drift, or new). For each non-empty
class invoke `Skill(wk-learn, args="adversarial-review")` encoding class,
mechanism, detection sketch, confidence — generic patterns only (no paths, lines,
logins, SHAs). Re-run for each new post-CI batch.

## Step 9.5: Wait for CI, Then Loop on New Comments

- Delegate CI polling to the configured CI skill; wait for `passed`, `failed`, or `canceled`.
- Failed/canceled → surface the failure and exit; fixing CI outranks further feedback.
- CI passes → re-run Step 3 against post-push HEAD; matching `(path, line, concern)` comments are already-addressed echoes.
- Genuinely new unresolved comments → loop: Step 4 (new findings) → Step 5 (same partition/one-at-a-time) → Steps 6–9 → Step 9.5 after the second push.
- Exit only when CI passes and the post-CI fetch surfaces no genuinely unresolved comments. Cap at 3 iterations; beyond that, surface the review-thrash loop to the user.

## Step 10: Final Summary

Emit the resolution summary (template: commands.md §10) covering branch sync,
comments processed, self-review/bot handling, fixes, deferrals, commits, replies,
threads resolved/open, conflicts, and PR URL.

## Step 11: Session Retro

Invoke `wk-retro` to capture session-level learnings. Mandatory on every
completion, including narrow directives.

## Quick Reference

| Trigger | Behavior |
|---|---|
| "resolve PR comments" / "address review feedback" / "respond to reviewers" / "fix PR #{number}" | Full workflow |
| "fix the comment" / "there's a description issue" with an open PR | Auto-activate on the open PR |
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
