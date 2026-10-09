---
name: wk-pr-update
description: >-
  Update a PR branch with the latest from its base — merge by default (no
  force-push), patch-replay when ≥5 commits ahead, rebase only on explicit
  opt-in; resolves conflicts, re-validates, pushes, then syncs the description.
  Use for "update PR", "merge in main", "sync with base", or a CI
  base-branch conflict.
argument-hint: '[<base-branch>]'
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Skill
  - "Bash(git:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr edit:*)"
  - "Bash(gh pr checks:*)"
  - Write
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  internal: false
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Update

## Hard Rules

1. **Never run on a dirty tree.** Stash or commit first; pre-flight refuses otherwise.
2. **Never force-push without `--force-with-lease`.** `--force` alone loses concurrent contributor work; lease aborts
   the push if the remote moved.
3. **Never silently drop commits.** Patch-replay must reproduce the branch's net diff exactly; if conflict resolution
   alters the diff, surface it before pushing.
4. **Never push without re-validation.** Branch must build + pass tests after integration, not before.
5. **Never skip PR description sync.** Updating the branch but leaving a stale PR body violates `wk-commit`'s PR Sync
   HARD RULE.
6. **All GitHub reads/writes follow [`wk-gh`](../gh/README.md).**
7. **Detect sequential identifier collisions before integration.** Compare new allocations on both histories; never
   leave a same-ID conflict for the merge.

## Stage 0: Pre-flight

Reject dirty tree (auto mode → abort); otherwise offer (a) stash, (b) commit via `wk-commit`, (c) abort. Capture
`$START_SHA` for safety net.

## Stage 1: Detect base, fetch, compute commit count

Validate PR is OPEN. Base: argument > PR base > repo default. Fetch and compute `$AHEAD`/`$BEHIND`. `$BEHIND == 0` →
exit early, already up to date. Then, before Stage 2:

- **Sequential identifier collision pre-flight:** compare artifacts introduced on each side since the merge base for
  every repository-wide sequential namespace (architecture decisions, migrations, schema identifiers, the repository's
  equivalents). Same identifier allocated to different artifacts → rename the branch-owned artifact to the next free
  identifier across both histories; reconcile filenames, headings, links, indexes, and inline references before
  integration; commit the atomic rename via `wk-commit`, then run merge, rebase, or patch-replay from a clean tree.
  Ownership ambiguous → stop and ask which artifact may move; never resolve by taking one side of the later textual
  conflict.
- **Merge-aware `$AHEAD` recomputation:** HEAD already contains a base-branch merge → recompute against the most recent
  base-merge; recomputed `$AHEAD ≤ 5` → prefer merge over patch-replay. Details:
  [`references/merge-aware-recompute.md`](references/merge-aware-recompute.md).
- **Independently-merged parent detection:** stacked parents merged into base via separate PRs make any strategy replay
  the duplicated prefix (massive add/add conflicts). Compare files added on the branch since the fork point against
  files added on base since the fork. Significant overlap → identify the boundary commit (last parent-originated commit
  before this branch's own work) and set `STACKED_PARENT_DETECTED=true`; Stage 2 routes to `rebase --onto` (Stage 3b).
- **Stacked chains — work bottom-up:** update parent first, verify, then integrate into child. Rediscover the live stack
  after each parent update. Compare trees (`git diff --quiet <verified-tip> <live-tip>`) before redoing work — a
  stack-tool rewrite gives new SHAs over an identical tree.

## Stage 2: Choose integration strategy

**HARD RULE — merge is the default.** `< 5` ahead or ready-for-review PR → merge. `≥ 5` ahead + draft → patch-replay.
Independently-merged parent → rebase `--onto`. User asks for linear history → rebase (explicit opt-in only). Full table
with rationale: [`references/strategy-table.md`](references/strategy-table.md).

## Stage 3a: Merge strategy (default)

```bash
git merge "$BASE_REF"
```

Conflicts → Stage 4; clean → Stage 5. Record `strategy=merge`; Stage 6 uses a normal push and preserves both local and
remote history if the remote branch advances before that push.

## Stage 3b: Rebase strategy (explicit opt-in)

`git rebase "$BASE_REF"`. Merged-parent branches → `--onto` to skip already-merged commits; squash-merged parent →
cherry-pick instead. After `--update-refs`, verify HEAD before committing. Conflicts → Stage 4. Stacked-branch handling
and no-op detection: [`references/rebase-strategy-details.md`](references/rebase-strategy-details.md).

## Stage 3c: Patch-replay strategy (`$AHEAD ≥ 5`)

Snapshot the net diff against the OLD merge-base, reset to new base, apply as one integration commit listing original
SHAs in the body. Conflicts → Stage 4. Procedure and commit format:
[`references/patch-replay-strategy.md`](references/patch-replay-strategy.md).

## Stage 4: Conflict resolution loop

**HARD RULE — never trust a rerere-cached resolution.** Recreate and re-resolve by hand. Prefer branch intent unless
base supersedes it. Regenerate lockfiles/generated output last. Auto mode resolves only trivial conflicts; semantic
conflicts prompt. Procedure, lockfile handling, abort path:
[`references/conflict-resolution.md`](references/conflict-resolution.md).

## Stage 5: Re-validate

Build + test **after** integration; pre-integration validation does not transfer.

- **Dependency install pre-check:** diff the dependency lockfile between pre- and post-integration base; changed →
  install dependencies before the suite (else a "missing dependency" error masquerades as a regression).
- Detect the test command from the signals in [`references/ecosystem-detection.md`](references/ecosystem-detection.md)
  (lockfile names, first hit wins, example invocations); run the suite plus type/lint checks if cheap.

Act on the outcome — take the first that matches:

1. All green → Stage 6.
2. Tests fail in code the integration touched → real regression: diagnose, fix on the integrated branch, re-validate.
   Never push a known-broken integration.
3. Tests fail in code unrelated to the integration → re-run on `$BASE_REF` to confirm; reproducible there → surface to
   the user but do not block the integration push.
4. No test command detected → note the gap, surface it to the user, proceed.

Validation surfaces a regression and user says "abort" → return the branch to its pre-integration state, retry after
fixing what broke it:

```bash
git reset --hard "$START_SHA"
```

**Behavior-preservation check:** diff `$START_SHA..HEAD` for removed env lookups, fallbacks, error handling, guards, and
spec blocks. Surface any removed behavior with no replacement; do not push until the user confirms. Scan categories:
[`references/behavior-preservation-check.md`](references/behavior-preservation-check.md).

## Stage 6: Push and sync PR description

Merge strategy → normal push. Rebase/patch-replay → `--force-with-lease`. Non-fast-forward after local integration →
fetch, inspect, merge, re-validate.
**HARD RULE:** after push, sync PR title/body via `wk-commit` PR Sync.
**HARD RULE:** preserve human-ticked test-plan checkboxes verbatim during the sync.
Push logic, remote-advance reconciliation, PR sync rules: [`references/push-and-sync.md`](references/push-and-sync.md).

## Stage 7: Final report

Write one line per stage actually run; stage skipped (no PR, no test command, etc.) → say so on its line, never omit the
line. **Always name the branch head before and after, plus the base it landed on.**

> "Updated `feat/foo` onto `origin/main`:
> - heads: `<before>` → `<after>`; base `origin/main` @ `<base>`
> - strategy: patch-replay (7 commits → 1 integration commit)
> - conflicts: 2 resolved (auto: 1, asked: 1)
> - validation: 142/142 tests passing, typecheck clean
> - PR #NNN synced and pushed"

Routing with `wk-workflow`, `wk-pr`, `wk-commit`:
[`references/skill-coordination.md`](references/skill-coordination.md).

## Post-Completion

Invoke `wk-learn pr-update`.
