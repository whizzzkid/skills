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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
---

# PR Resolve

Resolve PR review comments — implement fixes, draft responses, manage the full cycle. Verbatim commands:
[`references/commands.md`](references/commands.md). After compaction: resume at next uncompleted step; re-run
sync/fetch (Steps 2–3); never drop tail steps (9.4 learnings, 9.5 CI wait+loop, 11 retro).

## Hard Rules

1. **GitHub routing through `wk-gh`.** `gh api` only; canonical footer on every outbound body (commit-message trailer
   is different, never on bodies).
2. **Push/reply safety.** Require user confirmation; "merge-ready"/"land this" authorizes full lifecycle, "resolve
   comments" does not. Never force-push (exception: base-advance `--force-with-lease`). After push+reply → tail
   steps run.
3. **Reply substance.** Lead with what changed + commit SHA. Banned openers:
   `^(good catch|great|thanks|nice|well spotted|good point)`. Route via `wk-tone`.
4. **Resolve only worked threads.** Requires landed fix, explicit dismissal, or tracked deferral. Gates on fix
   landing, never CI.
5. **Commit discipline.** `wk-commit` conventions; one commit per triage unit; push once after all commits. Co-author
   only for PR author's work.
6. **Exclude self-review comments.** Do not triage/reply/resolve threads by PR author or current user. Surface
   external replies inside self-review threads.
7. **Base cleanliness.** Conflict markers or `$BEHIND > 0` → integrate first. Bot reviews are first-class;
   adversarial-review gates merge, not push.

## Step 1: Identify the PR

`gh pr view --json ...` (commands.md §1). Extract `{owner}`, `{repo}`, `{number}`, `{base_branch}`, `{head_sha}`.
Co-author: `$PR_AUTHOR != $CURRENT_USER` → treat both as self for exclusion, add `Co-authored-by:` per commit.

## Step 2: Sync Branch (commands.md §2)

**HARD RULE — Step 2 is unconditional.** Run fetch + ahead/behind before triaging any comment, whatever the branch
state; "already up to date" is an outcome, not a skip reason. Step 9's test-merge is not a sync substitute.

1. Conflict-marker pre-flight first: `git diff --check`; markers → resolve before fetch.
2. Reconcile remote PR branch → fetch, rebase if remote ahead.
3. Integrate base: HEAD has base merge + `$BEHIND <= 5` → `git merge`; otherwise delegate to `wk-pr-update` (no
   force-push).
- **HARD RULE — stacked PR CLOSED with its base branch deleted → recover before triaging** (commands.md §2).
- **HARD RULE — after each conflict resolution, audit for dropped base-side safety guards**; restore any present on
  the base but absent from the result.
- Stage from repo root (`git add` from subdir exits 128).

## Step 3: Fetch Unresolved Comments

Build comment map via commands.md §3 (GraphQL + REST). Emit before Step 4: `surfaces: inline=N reviews=N
conversation=N` (fetch all three surfaces) and `pending-self-review: yes|no → reply route`.

- Diff description against branch state → inject drift as `surface: agent_observation`.
- Classify: `Bot` → bot review; PR author/current user → self-review; other → reviewer.
- Active = unresolved + not self-review + not truly outdated. Sort by file path, then line.

## Step 4: Generate Suggestions

- **HARD RULE — honor the user's named target.** Name the exact finding before writing code; multiple findings → ask
  which, never infer; don't act on adjacent findings until the stated one is resolved.
- **HARD RULE: triage every comment before applying any fix.** One batched pass, never comment-by-comment
  fix/commit/push; bot reviews first. Read full context + reply chain before each fix.
- **Reproduce external findings before acting** — bot findings are hypotheses. Bot convergence:
  [`references/bot-convergence.md`](references/bot-convergence.md). Classification and special cases:
  [suggestion-format](references/suggestion-format.md).

## Step 5: Consult — Collect All Decisions First

**HARD RULE:** Consultation-only. Do not read files for editing, write code, commit, push, or post replies.

- **Partition:** `obvious_fixes[]` (tag == `obvious-fix`) or `judgment_required[]`. Rationale concedes comment is
  right → re-route to obvious. Auto Mode: confident disposition → decided, act and report.
- **Obvious fixes:** preview once (commands.md §5); default queue all. `stop` or `consult <indices>` diverts.
- **Judgment-required:** one at a time, full §4 block per message. Reserved keys: `a/e/d/t/s/r`.
- **HARD RULE — pre-emit gate (mechanical).** Before each message: exactly one `Comment {n}` header; restates full §4
  block (quote, fix, skip rationale).
- After all collected → report counts per bucket, then: "Moving to implementation."

## Step 6: Execute — Apply Fixes, Verify, Commit (commands.md §6)

- Step 5 decisions are binding — no mid-execution re-confirmation.
- Grep PR diff for sibling paths sharing issue class before each fix; probe real config path before editing
  shorthand-named files.
- Per fix: Edit → verify (build/lint/test; shared-helper → full-directory) → commit (one per triage unit) →
  record full SHA → update reply with commit link. Dismissals/deferrals: no code change, use Step 5 reply.

## Steps 7–8: Confirm, Push and Respond (commands.md §8)

- **Step 7 — Confirm Everything:** skip when Step 5 decisions are explicit (`a/e/d/t/s`). Fire only when: `(e)` not
  echoed verbatim, co-author name inferred, or ambiguous batch. Auto-mode: consent scoped per write class (push ≠
  reply ≠ resolve); re-confirm only the blocked action.
- **Step 8 — Push and Respond:** adversarial-review never dispatched here — push is ungated.
- History rewritten → re-check `$AHEAD`/`$BEHIND` before pushing.
- Draft + all reviewer threads resolved → `gh pr ready` without asking.
- Finalize per [`references/post-push-finalization.md`](references/post-push-finalization.md); re-query after all
  resolutions.

## Steps 9–11: Tail

- **Step 9 — Check Merge Conflicts:** test-merge `origin/{base_branch}` (`--no-commit --no-ff`). Clean → report.
  Conflicts → ask whether to resolve.
- **Step 9.4 — Capture Adversarial-Review Learnings. HARD RULE:** Emit `wk-learn adversarial-review` for every
  issue class surfaced before the CI wait — never skip; re-run per post-CI batch. Zero findings → one baseline
  learning. No paths/lines/logins/SHAs.
- **Step 9.5 — Wait for CI, Then Loop:** 1) CI poll via configured skill; failed/canceled → surface and exit. 2) CI
  passes → re-run Step 3; new unresolved → loop Steps 4–9. Cap: 3 iterations. 3) Before terminal summary: verify
  remote HEAD = pushed commit, CI terminal.
- **Step 10 — Final Summary:** template: commands.md §10.
- **Step 11 — Session Retro:** run `wk-retro` on every completion — never silently skip.

## Post-Completion

Invoke `wk-learn pr-resolve`.
