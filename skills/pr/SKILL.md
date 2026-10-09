---
name: wk-pr
description: >-
  Create a GitHub pull request and manage the post-PR workflow. Use when asked
  to create a PR, open a PR, push for review, or manage a stacked PR. Handles
  draft creation, stacking, CI polling, self-review, automated feedback, and
  marking ready.
argument-hint: '[optional: base branch for stacking]'
allowed-tools:
  - "Bash(git symbolic-ref:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(gh pr create:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr ready:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr reviews:*)"
  - "Bash(gh stack:*)"
  - "Bash(gh extension list:*)"
  - "Bash(gh api repos:*)"
  - Read
  - AskUserQuestion
  - Write
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
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR

Create and manage GitHub PRs: draft mode, stacking, and a post-creation workflow that ensures quality before ready.

## Hard Rules

0. **All GitHub reads/writes follow [`wk-gh`](../gh/README.md).** Unconditional: "skip the review" waives Rule 2 only,
   never `wk-gh` routing. Use `<<'EOF'` heredocs; reject empty/implausibly-short/shorter-than-submitted bodies.
1. **Preserve PR body metadata across rewrites** per `skills/pr/references/pr-description-metadata.md`.
2. **Adversarial review gates merge, not publish — once per change.**
   - Push / `gh pr create` / `gh pr ready` need no verdict; dispatch `wk-adversarial-review` once after Step 5 marks
     ready.
   - Merge requires clear review lineage; `blocked` → fix via `wk-commit`, re-invoke.
   - Finding-response commits and tree-identical rewrites preserve lineage; unmatched scope/refactor/logic gets one
     delta-scoped review.
   - **No-ask on findings:** incorporate immediately — fix blockers, fold improvements, commit via `wk-commit`. Pause
     only for genuinely ambiguous design decisions requiring user input.
3. **Resolve the true base before `gh pr create`.** Run Step 1's merge-base detection unconditionally. Do not call
   `gh pr create` until `$BEST_BASE` is computed this session. `--base` takes `$BEST_BASE` only — never hand-typed.
   `$BEST_BASE != $DEFAULT_BRANCH` → surface the A/B/C prompt first.
4. **Verify every claim from its source, not memory.** Re-read source files before writing behavioral descriptions;
   quote severity ladders directly. External-capability claims cite upstream source at composition time. Every
   identifier (run id, SHA, URL) in the body comes from a command run this turn.

## Step 1: Assess Scope

- **Detect the true base (run unconditionally):** merge-base distance to every candidate (default branch + open PR
  heads); closest wins. Algorithm: [`references/base-detection.md`](references/base-detection.md). `$BEST_BASE` is the
  only value passed to `--base`.
- **Measure scope against `origin/$BEST_BASE`** (fetch first — a stale local ref inflates LOC):

```bash
git fetch origin "$BEST_BASE" --quiet
git diff "origin/$BEST_BASE...HEAD" --shortstat
```

- >30 lines → ask about splitting via `wk-pr-break`. Pass `$BEST_BASE` through to Step 2 — never re-detect.
- Check open PRs for a related spec: [`references/check-open-prs-for-spec.md`](references/check-open-prs-for-spec.md).

## Step 2: Create Draft PR

PR creation is ungated; adversarial review runs after Step 5.

- **Always `--draft`** unless the user explicitly requests otherwise. Early-ready override (user directs immediate
  ready) or bot-ready gate (repo bot needs non-draft) → `gh pr ready` after creation.
- **Review waiver:** user says "no review" → suppress the Step 5 gate; `wk-gh` routing still applies.
- **Link source plan and spec:** plan found → link it (anchored to the phase section) under `## Meta`; link the spec
  too. "Link reference material" means URLs in the body, not copied files.

```bash
grep -rliE '<branch-phase-or-feature-keyword>' docs/plans docs/specs 2>/dev/null
```

- **Body template:** [`references/pr-template.md`](references/pr-template.md) — search order, population rules,
  verification guarantee. Superseded & closed PRs:
  [`references/superseded-closed-prs.md`](references/superseded-closed-prs.md).
- **Simple PR (fallback — no repo template):**

```bash
gh pr create --draft --base "$BEST_BASE" \
  --title "feat(scope): ✨ description" --body "$(cat <<'EOF'
## Summary
- What changed and why

## Test plan
- [ ] How to verify the changes
EOF
)"
```

- `--base "$BEST_BASE"` MUST be on every `gh pr create` (Hard Rule 3). Titles use conventional commit + emoji per
  `wk-commit`. Jira key detected via `wk-jira` → append `[<KEY>]` as the last title token.
- **Stacking:** use `gh stack` when available; probe `gh stack view`, non-zero → manual fallback. Details:
  [`references/gh-stack-stacking.md`](references/gh-stack-stacking.md).
  - **HARD RULE — recover an existing stack as one unit.** Never rebase/push layers independently. Snapshot refs →
    `gh stack rebase` → verify ancestry + tests → `gh stack push` → verify every remote head, current-head CI run,
    thread, and body-cited commit.
  - **Read merge order from `baseRefName`, never `part-N` labels** — labels drift after re-parent.
- **Body extras:** [`references/pr-body-extras.md`](references/pr-body-extras.md) — apply each matching sub-step.

## Step 3: Post-Creation Workflow

**HARD RULE — no early return after `gh pr create`.** Continue into the full lifecycle. Valid stopping points: CI
failing after 3 fix-loops, `blocked` review requiring user input, explicit user interjection. Side actions
(Slack/Jira/docs) are continue signals, not completion.

After draft creation (or pushing new commits to an existing PR), open it in the browser in the same response as
`gh pr create` (`gh pr view --web`), then:

1. **Sync description** — preserve metadata per Rule 1. **HARD RULE — no-ask on drift sync.** Never ask before
   syncing drift (PR body, self-review threads, Jira, docs); ask only when sync *content* is ambiguous.
2. **Invoke `wk-self-review` immediately.** **HARD RULE — self-review launches before the CI poll, never after CI
   green.** Do not start item 3 until the pending self-review draft is posted. **HARD RULE — never compose inline
   comment payloads directly from `wk-pr`.** Delegate to `wk-self-review` via the Skill tool; never call
   `gh api .../pulls/{n}/comments` (posts immediately, bypasses Submit).
3. **Poll CI** in the background; do not proceed while CI is failing.

## Step 4: Once CI is Green

1. **`wk-pr-resolve` drift check** — surface and resolve drift in description, self-review threads, reviewer comments.
2. **Sync description + check off CI items** — tick satisfied test-plan items; re-sync after every state change.
3. **HARD RULE — self-review is mandatory after CI green.** If Step 3's self-review was skipped, invoke now. No
   size/scope exemption; skipping requires explicit user instruction this session — never silent skip.
4. **Address automated feedback** — fetch via `gh api .../pulls/{number}/comments` + `gh pr reviews`. Fix small
   correct findings in-round; defer only large, contested, or out-of-scope ones.

## Step 5: Mark Ready

**HARD RULE — never end a turn with ANY draft PR whose work is done.** Every push carries an implicit `gh pr ready`
commitment (no wait on CI or verdict). Valid exits: user says hold-as-draft, or work genuinely unfinished. Iteration
rounds don't reset it; applies to every draft the session opened, not only the last.

- **HARD RULE — check off the test-plan boxes before `gh pr ready`, not after.** Tick boxes verified by local checks;
  leave unverified unticked; re-sync when CI goes terminal. Every identifier written while ticking comes from a
  command this turn (Rule 4).
- `gh pr ready` → confirm: "PR #{number} is marked ready for review: {url}"

### Adversarial-review gate (after ready, before merge)

Dispatch `wk-adversarial-review` — the completion gate and only dispatch point. CI runs concurrently. Lineage per
Rule 2.

**HARD RULE — verify CI for the *current* HEAD before merge, not before ready.** A green run on an earlier HEAD never
counts. An empty `statusCheckRollup` is NOT green — require checks present. Re-poll until terminal and green for
`headRefOid`:

```bash
gh pr view --json statusCheckRollup,headRefOid \
  --jq '{head: .headRefOid, checks: [.statusCheckRollup[]|(.status//.state)]|unique}'
```

**Trivial-PR fast path:** <25 lines + `clear` with zero findings → `gh pr merge --auto --squash`; quote verdict and
line count.

## Step 6: Session Retro

Invoke `wk-retro` after the PR is marked ready.

## Post-Completion

Invoke `wk-learn pr`.
