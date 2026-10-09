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
  version: "2026.10.09-005006"
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

Bring a PR branch up to date with its base → right integration strategy
for the branch's size, conflicts resolved interactively, work re-validated
after integration.

## Hard Rules

1. **Never run on a dirty tree.** Stash or commit first; pre-flight refuses otherwise.
2. **Never force-push without `--force-with-lease`.** `--force` alone loses concurrent
   contributor work; lease aborts the push if the remote moved.
3. **Never silently drop commits.** Patch-replay must reproduce the branch's net diff
   exactly; if conflict resolution alters the diff, surface it before pushing.
4. **Never push without re-validation.** Branch must build + pass tests after
   integration, not before.
5. **Never skip PR description sync.** Updating the branch but leaving a stale PR body
   violates `wk-commit`'s PR Sync HARD RULE.
6. **All GitHub reads/writes route through `wk-gh`.** Org scoping per `wk-gh` Step 1–2;
   PR-body sync emits the canonical outbound footer per `wk-gh` Step 4 once at the end
   of the body — never duplicated.
7. **Detect sequential identifier collisions before integration.** Compare new
   allocations on both histories; never leave a same-ID conflict for the merge.

---

## Stage 0: Pre-flight

Reject dirty tree (auto mode → abort). Capture `$START_SHA` for safety net.
Dirty tree → offer (a) stash, (b) commit via `wk-commit`, (c) abort.

---

## Stage 1: Detect base, fetch, compute commit count

Validate PR is OPEN. Base: argument > PR base > repo default. Fetch and compute
`$AHEAD`/`$BEHIND`. If `$BEHIND == 0`, exit early — already up to date.

### Sequential identifier collision pre-flight

Before Stage 2, compare artifacts introduced on each side since the merge base
for every repository-wide sequential namespace: architecture decisions,
migrations, schema identifiers, and the repository's equivalents.

- Same identifier allocated to different artifacts → rename the branch-owned
  artifact to the next free identifier across both histories.
- Reconcile filenames, headings, links, indexes, and inline references before
  integration; commit the atomic rename via `wk-commit`, then run merge,
  rebase, or patch-replay from a clean tree.
- Ownership ambiguous → stop and ask which artifact may move; do not resolve by
  taking one side of the later textual conflict.

### Merge-aware `$AHEAD` recomputation

If HEAD already contains a base-branch merge, raw `$AHEAD` overstates integration
work. Recompute against the most recent base-merge; if recomputed `$AHEAD ≤ 5`,
prefer merge over patch-replay. Details:
[`references/merge-aware-recompute.md`](references/merge-aware-recompute.md).

### Independently-merged parent detection

Stacked branches carry parent commits locally. When those parents merge into base
via separate PRs, any integration strategy replays the duplicated prefix → massive
add/add conflicts on files introduced by both histories.

Detect before Stage 2: compare files added on the branch since the fork point
against files added on base since the fork. Significant overlap → identify the
boundary commit (last parent-originated commit before this branch's own work) and
set `STACKED_PARENT_DETECTED=true`. Stage 2 routes to `rebase --onto` (Stage 3b).

---

### Stacked chains — work bottom-up

Update parent first, verify, then integrate into child. Rediscover the live stack
after each parent update. Compare trees (`git diff --quiet <verified-tip> <live-tip>`)
before redoing work — a stack-tool rewrite gives new SHAs over an identical tree.

## Stage 2: Choose integration strategy

**HARD RULE — merge is the default.** `< 5` ahead or ready-for-review PR → merge.
`≥ 5` ahead + draft → patch-replay. Independently-merged parent → rebase `--onto`.
User asks for linear history → rebase (explicit opt-in only).

Full strategy table with rationale:
[`references/strategy-table.md`](references/strategy-table.md).

---

## Stage 3a: Merge strategy (default)

```bash
git merge "$BASE_REF"
```

- Merge conflicts → enter Stage 4. Clean merge → enter Stage 5.
- Record `strategy=merge`; Stage 6 uses a normal push and preserves both local
  and remote history if the remote branch advances before that push.

---

## Stage 3b: Rebase strategy (explicit opt-in)

`git rebase "$BASE_REF"`. For merged-parent branches, use `--onto` to skip
already-merged commits. Squash-merged parent → cherry-pick instead. After
`--update-refs`, verify HEAD before committing. Conflicts → Stage 4.

Full rebase details, stacked-branch handling, and no-op detection:
[`references/rebase-strategy-details.md`](references/rebase-strategy-details.md).

---

## Stage 3c: Patch-replay strategy (`$AHEAD ≥ 5`)

Snapshot the net diff against the OLD merge-base, reset to new base, apply as one
integration commit listing original SHAs in the body. Conflicts → Stage 4.

Full procedure and commit format:
[`references/patch-replay-strategy.md`](references/patch-replay-strategy.md).

---

## Stage 4: Conflict resolution loop

**HARD RULE — never trust a rerere-cached resolution.** Recreate and re-resolve by hand. Prefer
branch intent unless base supersedes it. Regenerate lockfiles/generated output
last. Auto mode resolves only trivial conflicts; semantic conflicts prompt.

Full resolution procedure, lockfile handling, and abort path:
[`references/conflict-resolution.md`](references/conflict-resolution.md).

---

## Stage 5: Re-validate

Branch now has the base's changes integrated; the work must still build + pass tests
**after** that integration. Pre-integration validation does not transfer.

### Dependency install pre-check

Integration may invalidate the local dependency cache. Before running the test suite,
diff the project's dependency lockfile between pre- and post-integration base. If it
changed, install dependencies first — otherwise a "missing dependency" error
masquerades as a test regression.

Lockfile names, test-command detection signals (first hit wins), and example
invocations: [`references/ecosystem-detection.md`](references/ecosystem-detection.md).
Detect the test command from those signals, then run the suite plus type/lint checks if
cheap.

| Outcome | Action |
|---------|--------|
| All green | Proceed to Stage 6 |
| Tests fail in code the integration touched | Treat as a real regression — diagnose, fix on the integrated branch, re-validate. Do not push a known-broken integration. |
| Tests fail in code unrelated to the integration | Almost always means the base introduced the failure — re-run on `$BASE_REF` to confirm; if reproducible there, surface to the user but do not block the integration push. |
| No test command detected | Note the gap, surface it to the user, proceed (the user accepted the lack of automated coverage when they ran the skill) |

Validation surfaces a regression and user says "abort":

```bash
git reset --hard "$START_SHA"
```

Branch returns to its pre-integration state; retry after fixing what broke it.

### Behavior-preservation check

Diff `$START_SHA..HEAD` for removed env lookups, fallbacks, error handling, guards,
and spec blocks. Surface any removed behavior with no replacement. Do not push
until the user confirms.

Full scan categories and procedure:
[`references/behavior-preservation-check.md`](references/behavior-preservation-check.md).

---

## Stage 6: Push and sync PR description

Merge strategy → normal push. Rebase/patch-replay → `--force-with-lease`.
Non-fast-forward after local integration → fetch, inspect, merge, re-validate.
**HARD RULE:** after push, sync PR title/body via `wk-commit` PR Sync.
**HARD RULE:** preserve human-ticked test-plan checkboxes verbatim during the sync.

Full push logic, remote-advance reconciliation, and PR sync rules:
[`references/push-and-sync.md`](references/push-and-sync.md).

---

## Stage 7: Final report

One line per stage actually run:

> "Updated `feat/foo` onto `origin/main`:
> - heads: `<before>` → `<after>`; base `origin/main` @ `<base>`
> - strategy: patch-replay (7 commits → 1 integration commit)
> - conflicts: 2 resolved (auto: 1, asked: 1)
> - validation: 142/142 tests passing, typecheck clean
> - PR #NNN synced and pushed"

Stage skipped (no PR, no test command, etc.) → say so on its line; don't omit the line.

**Always name the branch head before and after, plus the base it landed on** —
rewritten history is not inspectable from the message alone, and both SHAs pre-empt
false-alarm "did you drop my commits?" corrections.
---

## Coordination with other skills

Routing between this skill and `wk-workflow`, `wk-pr`, and `wk-commit`:
[`references/skill-coordination.md`](references/skill-coordination.md).

---

## Quick Reference

| Trigger | Stages |
|---------|--------|
| `/wk-pr-update` | 0 → 7 |
| `/wk-pr-update <branch>` | 0 → 7 with explicit base |
| `wk-workflow` Phase 6 detects "behind base" | 0 → 7 (then resume CI fix loop) |
| Branch already up to date (`$BEHIND == 0`) | Exit at Stage 1 |
| Dirty tree | Abort at Stage 0 unless user picks stash/commit |
| Conflicts unresolvable | Reset to `$START_SHA`, hand back to user |

---

## Post-Completion

Invoke `wk-learn pr-update`.
