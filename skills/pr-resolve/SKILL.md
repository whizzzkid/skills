---
name: wk-pr-resolve
description: >-
  Address PR review comments interactively — implement fixes, prepare
  replies, drive the full resolution cycle. Use for "resolve PR comments",
  "address the feedback", or indirect refs ("fix the comment", "fix this on
  the PR") whenever an open PR exists on the branch. Prefer activating over
  asking.
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
  version: '2026.07.09-172450'
---

# PR Resolve

Interactively address PR review comments — implement fixes, draft responses,
manage the full resolution cycle from sync to summary. Verbatim command blocks
and the suggestion-format template live in
[`references/commands.md`](references/commands.md); use them exactly.

## Resume After Compaction

Resumed mid-skill → resume at the next uncompleted step (never restart from Step
1), re-run possibly-stale sync/fetch (Steps 2–3), and never drop tail steps absent
from the summary (9.4 learnings, 9.5 CI wait+loop, 11 retro).

## Hard Rules

0. **Scope GitHub payloads through `wk-gh`.** Satisfy its org-scope gates before
   any GitHub read/write; `gh api` is the only transport. Append the canonical
   outbound footer to every reply, PR-body edit, and thread message at render time.
1. **Never push without explicit user confirmation.**
   - **Holds under Auto Mode.** A user question/redirect ("why did you not
     push?") is a reconsider prompt, not a go-ahead — require explicit
     yes/approve/proceed (same for Hard Rule 4 force-push). Auto Mode acts on
     evaluated recommendations, never on intent inferred from a question.
2. **Never post reply comments without explicit user confirmation.**
   - **HARD RULE — every reply/dismissal body leads with substance (what
     changed, the decision, the commit SHA), never a pleasantry.** Praise/thanks
     openers ("Good catch!") are banned unconditionally. Route through
     `Skill(wk-tone)` before render; the ban holds even if routing is skipped.
3. **Only resolve threads you actually worked on** — after a fix, explicit
   dismissal, or tracked deferral. Never resolve follow-up questions, skipped,
   rethink-pending, or ordinary self-review threads.
   - **Resolution gates on the fix landing, never on CI.** Pushed commit
     addressed the finding → resolve in Step 8 now, never defer to the Step 9.5
     CI wait (later CI failures are a later commit's context).
   - **A reply answering/fixing a finding auto-resolves its thread** — no
     separate confirmation ask; hold open only a genuine follow-up question.
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
   - **User-touched reviewer threads: one narrow follow-up** — on a reviewer/bot
     thread the user already replied to, post a single follow-up only when the
     session changed the finding or a new item needs callout. Still requires
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
13. **Never submit the author's own pending self-review, and never re-prompt for
    it.** Submitting is destructive/irreversible — it publishes work the human is
    holding for manual release (`wk-self-review` checkpoint). "Do not bother me
    with it" means leave it alone, not submit it. Note it once, route around via
    the GraphQL resolve path (Step 3); submit only on an explicit "submit my
    review" instruction. Re-prompting >1×/session is a violation.

## Step 1: Identify the PR

Run `gh pr view --json ...` (commands.md §1). No PR detected → ask for
number/URL. Extract `{owner}`, `{repo}`, `{number}`, `{base_branch}`,
`{head_sha}`.

Detect co-author scenario: capture `$PR_AUTHOR`/`$CURRENT_USER` (commands.md §1).
`$PR_AUTHOR != $CURRENT_USER` → co-author session: record both logins, treat both
as self for comment exclusion, add the PR author `Co-authored-by:` per commit.

Announce:
> "Resolving review comments on PR #{number}: *title*. Base: `{base_branch}`."

Co-author session adds:
> "Note: PR authored by @{pr_author}. Commits will include co-author attribution.
> Comments from both you and @{pr_author} are excluded from triage."

## Step 2: Sync Branch

Sync with both base and remote PR branch before triaging. Commands: commands.md §2.

- **HARD RULE — conflict-marker pre-flight is the first action.** Before any
  fetch or comment read, run `git diff --check`. Any markers → resolve (or
  delegate to `wk-pr-update`) to a clean tree first. Never triage or fix on a
  conflicted tree — it embeds markers in commits or builds suggestions on a stale diff.
- **Reconcile remote PR branch first** — fetch, rebase onto `origin/$HEAD_BRANCH`
  if remote is ahead. Keeps next push fast-forward; avoids a divergent merge.
- **Integrate the base branch** — merge-aware pre-check: HEAD already has a base
  merge and `$BEHIND <= 5` → plain `git merge`. `$BEHIND > 0` obligates the merge
  before reading one comment; reporting the count and continuing is a violation.
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
  - **A clean local merge does not clear GitHub's `mergeable: CONFLICTING` when
    upstream deleted a file the branch modified** — GitHub recomputes from the
    original PR ancestor, which still holds the file. `mergeable: CONFLICTING`
    after a merge → pivot to the rebase above, never a second merge.
- **HARD RULE — audit dropped safety guards after each conflict resolution.** The
  base side (HEAD during rebase) is canonical `origin/$BASE_BRANCH`; a guard there
  was intentional. Diff both sides for signal/cleanup primitives (signal stops,
  `defer`, channel closes); any on the base side but absent from the result is a
  dropped guard — restore unless the incoming commit removed it with rationale.
  Green compile/tests do **not** prove it unneeded; block until each absence is confirmed.
- **Stage resolved files from the repo root** — cwd may be a subdir where `git add`
  exits 128 (command in commands.md §2; here and Step 6).
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

- **Bot REST comment IDs are unstable; thread node IDs are not.** After a bot replaces its review the REST `databaseId` 404s for *all* ops. Read bodies via GraphQL `reviewThreads` → `comments.nodes[0].body`, not REST `GET /pulls/{n}/comments/{id}` (reply-404: Step 8).

**Agent-observed drift is first-class feedback.** Actively read the current PR
description and diff it against branch state (commits, file list, test plan, CI)
before triaging — never rely on passively noticing drift. Inject any staleness,
missing section, or metadata/diff/docs drift as `surface: agent_observation`
(`bot_badge` flag); triage like any finding.

**Classify comment authors:**

| `user_type` | Pattern | Classification |
|---|---|---|
| `Bot` | Any bot suffix or custom bot login | Bot review |
| `User` | Matches PR author login | Self-review |
| `User` | Matches current user login in co-author session | Self-review |
| `User` | Any other login | Reviewer |

**Pre-check pending self-reviews at Step 3, never at reply time.** A pending
review blocks reply posting (HTTP 422); handle per Hard Rule 13 + commands.md §3.

**Filter and group:**

- Active = thread unresolved, not self-review, not truly outdated.
- Outdated thread, concern gone → record auto-skipped and resolve. Unresolved outdated → still open feedback.
- Sort active comments by file path then line; separate bot from human in the summary.
- Report skipped self-review threads and external replies hidden inside them.

## Step 4: Generate Suggestions

**HARD RULE — honor the user's named target.** User points to a specific artifact (comment, CI log, bot review) → name the exact finding before writing code; multiple findings in it → ask which, never infer; don't act on adjacent findings until the stated one is resolved.

**Bot / non-convergence handling:**

- Track bot thrash by `(path_prefix, concern_class)` and total active findings per round.
- Stop and ask before another fix when: same pair re-fires 3×; totals stop falling 2 rounds running; or a new finding contradicts an accepted fix — unless dismissal is Auto-Mode-confident (act, no plan).
- Re-fires on prose → grep code/CI/prompt reading its *content* (not just path) before rewording; none → delete/restructure.
- Bot reply: documented command syntax, else a generic reply tagging the bot with the decision.
- **Surface prior-round dismissals.** Before a judgment-required finding, check
  the session `dismissed` list and prior-round notes for the same field/concern
  class — a bot re-firing on a dismissed field from a new angle is the same
  decision. Found → surface the prior reason inline, default to `(d)`, ask once.

**All-Minor bulk-dismiss gate.** Every active finding Minor and each has a
plausible skip rationale → offer one bulk action before per-item triage:

> "All {N} findings are Minor. Bulk dismiss all, or triage individually?
> (a) dismiss all  (b) triage individually"

**Order — HARD RULE: triage every comment before applying any fix.** Apply
accepted fixes as one batched pass; never loop comment-by-comment through
fix/commit/push.

- Process bot reviews first, then human comments.
- For each: read full file context, the comment, and reply chain before a fix.

**Org-specific policy questions.** Reviewer question touches org policy → search
the configured KB first and cite an authoritative doc; fall back to general
knowledge only if the KB is empty, flagging it. Skip for code-level intent,
design rationale, or test-coverage questions.

**Missing-documentation findings.** Before surfacing a bot "undocumented
behavior/rationale/trade-off" finding, grep the diff, touched files, and repo
docs; covered (or code is unambiguous) → cite and dismiss; else present normally.

**Verify pattern applicability before copying.** A finding citing a pattern used
elsewhere → confirm the scenario matches (auth, runtime state, credential
ownership) first; precedent alone never proves this context needs it.

**Suggestion format** — see commands.md §4. Every suggestion gives `Why this fix`
/ `Why skip` reasoning; `{bot_badge}` = `🤖 (bot)` for bots, else omitted. Be
honest in the skip rationale; none exists → say so.

**Detect design flaws.** Before drafting a localized patch, decide whether the
comment signals a design flaw (triggers: "this might not trigger", "depends on
X", "what happens if {edge}", "why do we need this", "duplicated with", "contract
unclear"). Fired → present the design change first, a clarifying reply second; in
Step 5 `(a)` applies the design option unless edited.

**Classify suggestions** — tag each `obvious-fix` or `judgment-required`:

| Tag | Condition |
|---|---|
| `obvious-fix` | Skip rationale empty, "no valid reason", "no good reason to skip", `—`, or otherwise concedes the comment is right. **Fail-open** (swallowed errors, silent returns) in a script writing/publishing external artifacts also lands here, absent an idempotent-pass-through requirement. |
| `judgment-required` | A real tradeoff, false-positive possibility, scope question, multiple valid approaches, or security/performance judgment exists. |

Default to `judgment-required` when uncertain.

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
re-route into `obvious_fixes[]`. Severity does not bypass this. Auto Mode: a
finding with a confident, evidence-backed disposition (apply *or* dismiss) is
likewise decided → `obvious_fixes[]`, act and report; never confirm per-item.
Consult is for genuine tradeoffs only.

**Bulk-queue preview for obvious fixes.** Obvious-fix items exist → present the
bulk-queue preview (commands.md §5) once before queueing. Default
(silence/affirmative/unrelated): queue all into `fixes_to_apply` and proceed. Only
explicit `stop` or `consult <indices>` diverts.

**Present one judgment-required comment at a time.** For each, present the full §4
suggestion format then the per-comment prompt (commands.md §5). `a`, `e`, `d`,
`t`, `s`, `r` are reserved; extra options use other letters and must not redefine
them. Wait for the response before the next comment.

**HARD RULE — pre-emit gate (mechanical).** Before sending a Step 5 message,
hard-stop unless both hold:

- **Count:** exactly one `Comment {n}` header — > 1 → split, one per message (a
  batched prompt lets the user reply `a a d` — forbidden).
- **Completeness:** the item restates its full §4 block — comment body/quote,
  fix, skip rationale; reconstruct any missing piece first. A bare letter/code
  ref (`A+C, D, B`) is unreadable even when the count passes.

**Decision handling** — record exactly one outcome per decision; `a`/`e`/`d`/`t`
all mark `resolve_after_push`. Per-letter record shapes, reply drafts, and
`d`/`r` semantics: commands.md §5.

**After all decisions collected**, report the counts per bucket (obvious queued,
accepted, follow-ups, dismissals, deferrals, skipped), then: "Moving to
implementation — applying all accepted fixes now, one commit per triage unit,
verifying each."

## Step 6: Execute — Apply Fixes, Verify, Commit

Apply all Step 5 decisions: process `fixes_to_apply`, `dismissals`, `deferrals`
in order. Commands: commands.md §6.

**Issue-class scan before each fix.** Identify the issue class; grep the full PR
diff for sibling paths sharing it — per-class grep targets in commands.md §6 (a
refactor clones the defect onto sibling lines). Include siblings in the same
commit only when they share the triage unit or were merged by Step 4.

**Probe the real config path before editing a file named by user shorthand.**
Shorthand names the concept, not the path — CI/pipeline step config often lives
in a generator/template file. Grep the step key (`grep -rn '<step-key>'
<config-dir>`) and edit the file the grep returns, not the named one.

**For each fix:**

1. Apply the change with Edit.
2. Verify with the repo's build/lint/test command. No build system → warn once. Verification fails → ask whether to fix, commit anyway, or skip. Go file → `goimports -local <module> -w <file>` before staging (not `-l`, which only lists → false pass; `go test` misses import-grouping CI rejects).
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
review" → ask: formal PR Review submission, or threaded replies? Default to the
former unless they confirm the latter.

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
the divergence-guard cherry-pick above. Never bare `git push -f`. Auto-mode
classifier blocks the authorized `--force-with-lease` (HR4, rebase approved) → set
`dangerouslyDisableSandbox: true` on that Bash call; never stop to ask the user to
run it manually — the authorization is already in scope.

**Sync PR description immediately after push — HARD RULE:** Update the PR body
before posting replies or resolving threads, even when it looks current.

- Preserve metadata lines.
- Verify commit links, test-plan checkboxes, CI status, remaining work, known limitations, and file lists before declaring no drift.
- No drift → log an explicit "no drift detected" line naming the compared fields.
- **Never assert a result the agent cannot confirm.** Gate Testing/Results on known evidence (diff, CI, user statement); no evidence → honest placeholder (`Pending — <how to exercise>`), never a templated "build completed successfully".

**Re-check self-review and docs drift (every push):**

- Re-read agent-posted self-review comments; a fix changed the code a comment describes → correct or resolve it.
- Invoke `wk-docs` against files touched this session; update docs/specs/README when behavior, signatures, or config changed.

**Post replies, reactions, resolve threads.** Re-run the pending self-review
check before the first reply; route around the author's own pending review per
Hard Rule 13 (never submit it). Post
replies sequentially, routed by surface — full routing, reaction map, ID-refresh,
and `404`/`NOT_FOUND`/outdated-thread/in-place-bot handling in commands.md §8.
Key rules:

- Quote the original on issue-comment replies; suggestions split from one issue
  comment (Step 4) → **one combined reply** (no sub-section replies).
- Refresh bot thread IDs against post-push HEAD before bot replies; skip dropped findings.
- Post-push comments matching `(path, line, concern)` from this session are
  already-addressed echoes: reply with the commit link, resolve, no re-prompt/re-commit.

## Step 9: Check Merge Conflicts

Test-merge `origin/{base_branch}` with `--no-commit --no-ff` (commands.md §9).
Clean → abort and report success. Conflicts → abort and ask whether to resolve
them now.

## Step 9.4: Capture Adversarial-Review Learnings

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class surfaced
before the CI wait — never skip for short/routine sessions. Zero findings → one
baseline-holding learning.

Classify processed comments into generic issue classes (security, validation,
exception handling, race/TOCTOU, retry/timeout, defensive/dead guard,
API/external-call shape, docs/comment-accuracy drift, or new). For each non-empty
class invoke `Skill(wk-learn, args="adversarial-review")` encoding class,
mechanism, detection sketch, confidence — generic patterns only (no paths, lines,
logins, SHAs). Re-run per post-CI batch.

## Step 9.5: Wait for CI, Then Loop on New Comments

- Delegate CI polling to the configured CI skill; wait for `passed`/`failed`/`canceled`.
- Failed/canceled → surface the failure and exit; fixing CI outranks feedback.
- CI passes → re-run Step 3 against post-push HEAD (matches are already-addressed echoes, per Step 8).
- Genuinely new unresolved comments → loop: Step 4 (new findings) → Step 5 (same partition/one-at-a-time) → Steps 6–9 → Step 9.5 after the second push.
- Exit only when CI passes and the post-CI fetch surfaces no genuinely unresolved comments. Cap at 3 iterations; beyond that, surface the review-thrash loop to the user.

## Step 10: Final Summary

Emit the summary (template: commands.md §10) covering branch sync,
comments processed, self-review/bot handling, fixes, deferrals, commits, replies,
threads resolved/open, conflicts, and PR URL.

## Step 11: Session Retro

Invoke `wk-retro` to capture session-level learnings. Mandatory on every
completion, including narrow directives.

## Quick Reference

| Trigger | Behavior |
|---|---|
| "resolve PR comments" / "address review feedback" / "fix PR #{number}" | Full workflow |
| "fix the comment" / "description issue" with an open PR | Auto-activate on the open PR |
| Session ends | Emit adversarial-review learnings, then run `wk-retro` |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for verification commands
- Commit signing configured

---

## Post-Completion

Invoke `wk-learn pr-resolve`.
