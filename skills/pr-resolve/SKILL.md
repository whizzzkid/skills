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
env-vars:
  - WK_SKILLS_EMPLOYEE_EMAIL
metadata:
  author: whizzzkid
  version: "2026.08.28-053317"
  model:
    openai: gpt-5.6-terra
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

1. **GitHub routing through `wk-gh`.** Org-scope gates before any read/write;
   `gh api` is the only transport. Every outbound body carries the canonical
   `wk-gh` footer — lint each body independently before each mutation. The
   commit-message trailer is a DIFFERENT string, never shipped on an outbound body.
2. **Push and reply safety.** Never push or post replies without explicit user
   confirmation. "make it merge-ready"/"land this" authorizes the full lifecycle;
   "resolve comments" alone does not. Never force-push — exception: base-advance
   rebase may `--force-with-lease`. After push + reply → tail steps (9–11) run
   without pause.
3. **Reply substance.** Every reply/dismissal body leads with substance (what
   changed, the decision, the commit SHA). Banned openers: `^(good catch|great|
   thanks|nice|well spotted|good point)` — pre-emit lint rejects. Route through
   `wk-tone`.
4. **Only resolve threads you actually worked on.** Resolution requires a landed
   code fix, explicit dismissal, or tracked deferral. Resolution gates on the fix
   landing, never on CI. A reply fixing a finding auto-resolves its thread.
5. **Commit discipline.** Never commit without verification. Follow `wk-commit`
   conventions (conventional + emoji, signed, HEREDOC). One commit per triage unit;
   push once after all commits. Co-author attribution only when incorporating
   the PR author's work; agent-only fixes → `Assisted-by: Claude` only.
6. **Exclude self-review comments.** Do not triage, reply to, or resolve threads
   authored by the PR author/current user. Resolve submitted self-review threads
   only at merge readiness. Surface external replies inside self-review threads.
7. **Base cleanliness and review gates.** Never triage on an unclean base —
   conflict markers or `$BEHIND > 0` → integrate first (Step 2). Include bot
   reviews as first-class feedback; a blocking finding with a concrete fix →
   `obvious-fix`. Adversarial-review gates merge, not push — never dispatched
   here. Implement handoff documents before deleting them. Never submit the
   author's pending self-review; note once, route via GraphQL resolve. User
   brevity scopes volume, not the step sequence.

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
> "Note: PR authored by @{pr_author}. Commits carry co-author attribution;
> comments from both are excluded from triage."

## Step 2: Sync Branch

Sync with both base and remote PR branch before triaging. Commands: commands.md §2.

- **Conflict-marker pre-flight is the first action** (Hard Rule 14): run `git diff
  --check`; any markers → resolve (or delegate to `wk-pr-update`) to a clean tree
  before any fetch or comment read — a conflicted tree embeds markers in commits or
  builds suggestions on a stale diff.
- **Reconcile remote PR branch first** — fetch, rebase onto `origin/$HEAD_BRANCH`
  if remote is ahead.
- **Integrate the base branch** (Hard Rule 14) — merge-aware pre-check: HEAD already
  has a base merge and `$BEHIND <= 5` → plain `git merge`.
- Otherwise delegate to `wk-pr-update` (must preserve no-force-push); on any
  reported blocker (unresolvable conflict, validation regression, forced push) →
  stop and surface it.
- **Base-advance conflict (upstream PR merged)** → rebase onto the new base; a clean
  local merge may not clear `mergeable: CONFLICTING`, so pivot to rebase (commands.md §2).
- **HARD RULE — stacked PR CLOSED with its base branch deleted → recover before
  triaging** (recovery sequence and prevention: commands.md §2).
- **HARD RULE — after each conflict resolution, audit for dropped base-side
  safety guards**; restore any present on the canonical base but absent from the
  result. Detail: conflict-preflight.md.
- **Stage resolved files from the repo root** — cwd may be a subdir where `git add`
  exits 128 (command in commands.md §2; here and Step 6).
- **HARD RULE — Step 2 is unconditional.** Run fetch + ahead/behind before
  triaging any comment, whatever the branch state. "Already up to date" is an
  outcome of running it, not a reason to skip. Step 9's test-merge is a conflict
  check, not a sync substitute — a skipped Step 2 is a violation even when Step 9
  clears clean.

## Step 3: Fetch Unresolved Comments

Build the comment map via commands.md §3 — GraphQL for unresolved threads, REST
for details. Surfaces, map fields, and pending-review handling are specified there.

**Gate — emit these two lines before Step 4 (enforced as output):**

- `surfaces: inline=N reviews=N conversation=N` — fetch ALL THREE
  (`/pulls/{n}/comments`, `/pulls/{n}/reviews`, `/issues/{n}/comments`); a surface
  you did not fetch prints `0` — a fetch bug, not an empty surface; bot bulk
  findings hide in conversation comments.
- `pending-self-review: yes|no → reply route` — pre-check at fetch time, never at
  reply time; a pending review blocks replies (422) and PATCH edits to its own
  comments (404). Route per Hard Rule 13 + wk-gh.


**Important — agent-observed drift is first-class feedback.** Diff PR description
against branch state before triaging; inject drift as `surface: agent_observation`
(`bot_badge` flag).
- **Capture the original** (`gh pr view --json body`) before replacing.
- **Version-tag drift:** query tags/releases and flag mismatches (non-skippable).

**Classify authors:** `Bot` login → Bot review; `User` matching the PR-author
login (or the current user in a co-author session) → Self-review; any other
`User` → Reviewer.

**Filter and group:**

- Active = thread unresolved, not self-review, not truly outdated.
- Outdated thread, concern gone → record auto-skipped and resolve. Unresolved outdated → still open feedback.
- Sort active comments by file path then line; separate bot from human in the summary.
- Report skipped self-review threads and external replies hidden inside them.

## Step 4: Generate Suggestions

**HARD RULE — honor the user's named target.** User points to a specific artifact (comment, CI log, bot review) → name the exact finding before writing code; multiple findings in it → ask which, never infer; don't act on adjacent findings until the stated one is resolved.

**Bot / non-convergence handling** — follow
[`references/bot-convergence.md`](references/bot-convergence.md).

**Order — HARD RULE: triage every comment before applying any fix.** Apply
accepted fixes as one batched pass; never loop comment-by-comment through
fix/commit/push. Process bot reviews first, then human comments.

- For each: read full file context, the comment, and reply chain before a fix.
- **Reproduce externally-sourced findings before acting** — bot/scanner findings
  are hypotheses; reproduction settles real-defect vs. false-positive. Verify
  code-path agreement, env-var forwarding contracts, and framework compilation
  pipelines before calling "false positive."
- **Shell/wrapper hypothesis → inspect the job log's exact rendered command and
  downstream sentinel.** A matching passing sentinel outranks static speculation.

**Suggestion format, classification, and special cases** — see
[suggestion-format](references/suggestion-format.md) for: `obvious-fix` vs
`judgment-required` tags, merge/split/convergence rules, all-minor bulk-dismiss
gate, design-flaw detection, fix-footprint gate, org-policy KB lookup, and
docs-ahead-of-code stacked PR handling.

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

**Bulk-queue preview for obvious fixes.** Present commands.md §5 preview once;
default: queue all into `fixes_to_apply`. Only `stop` or `consult <indices>`
diverts.

**Present one judgment-required comment at a time.** For each, present the full §4
suggestion format then the per-comment prompt (commands.md §5). `a`, `e`, `d`,
`t`, `s`, `r` are reserved; extra options use other letters and must not redefine
them. Wait for the response before the next comment.

**HARD RULE — pre-emit gate (mechanical).** Before each Step 5 message:

- **Count:** exactly one `Comment {n}` header per message.
- **Completeness:** restates full §4 block (comment body/quote, fix, skip
  rationale); bare letter/code refs are unreadable.

**Decision handling** — record exactly one outcome per decision; `a`/`e`/`d`/`t`
all mark `resolve_after_push`. Per-letter record shapes, reply drafts, and
`d`/`r` semantics: commands.md §5.

**After all decisions collected**, report the counts per bucket (obvious queued,
accepted, follow-ups, dismissals, deferrals, skipped), then: "Moving to
implementation — applying all accepted fixes now, one commit per triage unit,
verifying each."

## Step 6: Execute — Apply Fixes, Verify, Commit

Apply all Step 5 decisions (`fixes_to_apply`, `dismissals`, `deferrals`) in
order. Commands: commands.md §6.

**Important — Step 5 decisions are binding; never pause mid-execution to
re-confirm a decided action.** The only in-flow stop is a verification failure
(sub-step 2).

**Issue-class scan before each fix.** Grep the full PR diff for sibling paths
sharing the issue class (targets: commands.md §6). Include siblings only when
they share the triage unit or were merged by Step 4.

**Probe the real config path before editing a file named by user shorthand.**
Shorthand names the concept, not the path — CI/pipeline step config often lives
in a generator/template file. Grep the step key (commands.md §6) and edit the
file the grep returns, not the named one.

**For each fix:**

1. Apply the change with Edit.
2. Verify with repo build/lint/test. No build system → warn once. Verification fails → ask fix/commit-anyway/skip. Go → run `goimports` before staging (commands.md §6).
   - **Shared-helper refactor → full-directory verification.** Change touches a method called from ≥2 sites → run full spec/test dir for all call sites. Narrow verification after shared-contract change is a violation.
3. Commit one commit per triage unit (HEREDOC template, commands.md §6; co-author trailer per Hard Rule 9).
4. Record the full SHA immediately: `FULL_SHA=$(git log --format=%H -1 <short_or_HEAD>)`.
5. Update the drafted reply with a clickable commit link, full SHA from git (never infer from a short SHA; format in commands.md §6).

**For each dismissal or deferral.** No code change — use the Step 5 reply.
Deferrals reference the user-provided ticket; never create tickets here.

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

**Auto-mode sequential consent.** The classifier scopes consent per external-write
class (push ≠ reply ≠ resolve); a single "yes" to the combined plan may not clear
all three. When a downstream action is denied, re-confirm only the narrow blocked
action — never re-pitch the full plan or treat the re-ask as an error.

**Disambiguate "review" objections.** "don't post the self-review" / "skip the
review" → ask: formal PR Review submission, or threaded replies? Default to the
former unless they confirm the latter.

## Step 8: Push and Respond

Commands: commands.md §8.

**Adversarial-review gate — never dispatched here.** Push is ungated; this skill
only *reads* the record, so N resolve cycles cost zero extra runs. Fixes after the
cleared SHA are swept by the one delta-scoped re-review the completion gate owns
before merge; a recorded `blocked` → fix each in a fresh atomic commit, batched.

**Push & divergence guard.** History rewritten this session → re-check
`$AHEAD`/`$BEHIND` and reconcile before pushing. `git push`; rejected
non-fast-forward → reconcile per commands.md §8 (decision, cherry-pick, and the
Hard Rule 4 `--force-with-lease` exception live there).

**Draft PR → mark ready.** Push landed and every reviewer thread resolved on a
draft PR → run `gh pr ready {number}` without being asked; a fully-resolved draft
is review-ready.

**Finalize the pushed PR** — follow
[`references/post-push-finalization.md`](references/post-push-finalization.md)
before replying or resolving threads. After all resolutions, re-query
unresolved threads; any addressed finding still open → resume resolve.

## Step 9: Check Merge Conflicts

Test-merge `origin/{base_branch}` with `--no-commit --no-ff` (commands.md §9).
Clean → abort and report success. Conflicts → abort and ask whether to resolve
them now.

## Step 9.4: Capture Adversarial-Review Learnings

**HARD RULE:** Emit `wk-learn adversarial-review` for every issue class surfaced
before the CI wait — never skip. Zero findings → one baseline learning.

Classify into generic issue classes; invoke `Skill(wk-learn,
args="adversarial-review")` per non-empty class encoding class, mechanism,
detection sketch, confidence — no paths/lines/logins/SHAs. Re-run per post-CI batch.

## Step 9.5: Wait for CI, Then Loop on New Comments

- Delegate CI polling to the configured CI skill; wait for `passed`/`failed`/`canceled`.
- Failed/canceled → surface the failure and exit; fixing CI outranks feedback.
- CI passes → re-run Step 3 against post-push HEAD (matches are already-addressed echoes, per Step 8).
- Genuinely new unresolved comments → loop: Step 4 (new findings) → Step 5 (same partition/one-at-a-time) → Steps 6–9 → Step 9.5 after the second push.
- Exit only when CI passes and the post-CI fetch surfaces no genuinely unresolved comments. Cap at 3 iterations; beyond that, surface the review-thrash loop to the user.
- **Before terminal summary → re-fetch the PR.** Verify remote HEAD equals the pushed commit, every recorded
  response/resolution matches its decision, and required CI is terminal and reported. Mismatch → resume the owning
  step; local progress never completes a remote PR.

## Step 10: Final Summary

Emit the summary (template: commands.md §10) covering branch sync,
comments processed, self-review/bot handling, fixes, deferrals, commits, replies,
threads resolved/open, conflicts, and PR URL.

## Step 11: Session Retro

**Important — run `wk-retro` on every completion**, including narrow directives and
autonomous/Auto-Mode runs. A full-cycle run invokes it or announces the deferral and
why — never silently skip.

## Quick Reference

| Trigger | Behavior |
|---|---|
| "resolve PR comments" / "address review feedback" / "fix PR #{number}" | Full workflow |
| "fix the comment" / "description issue" with an open PR | Auto-activate on the open PR |

---
