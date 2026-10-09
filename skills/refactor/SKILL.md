---
name: wk-refactor
description: >-
  Validate that a refactor preserved behavior. Auto-invoked after a
  rebase/patch-replay, after a conflict resolution, after extracting a
  helper / moving a file / renaming a symbol / splitting a module, and
  before any "ready for review" on a movement-dominated diff. Manual:
  `/wk-refactor [<pr>]`.
argument-hint: '[<pr-number-or-url>]'
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - "Bash(git:*)"
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - Write
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: workflows
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

# Refactor

Prove a refactor changed only shape: passing tests and clean lints prove new paths work, not that paths that should
still exist survived. Flow: detect kind → two-axis diff → removed-line audit → source-of-truth compare → surface
findings → confirm or fix.

## When this fires

Required: after `wk-pr-update` finishes a rebase or patch-replay; after `wk-pr-resolve` resolves any conflict; after the
agent extracts a helper, moves a file, renames a symbol, or splits a module; before any "ready for review" /
`gh pr ready` on a movement-dominated diff. Manual: `/wk-refactor` or `/wk-refactor <pr>`.

- Never block integration: produce findings the user must acknowledge.
- **Do not** substitute the lint/test gate: those verify new code; this verifies the old code isn't gone.

## Hard Rules

1. **Tests passing is not preservation.** Suite covers paths that *exist*; preservation requires verifying paths that
   *should still exist* are still there. Never claim refactor correctness on a green suite alone.
2. **Conflict resolution by `--theirs` / `--ours` is a red flag.** Picking one of two valid functional paths wholesale →
   internally-consistent but externally-regressed code. Audit every `--theirs`/`--ours` resolution for behavior loss
   before this skill is satisfied.
3. **A pure refactor changes which file behavior lives in, not which behavior exists.** Disappeared tests must be either
   (a) explicitly out-of-scope (PR description says so), or (b) renamed/moved to a new test file asserting the same
   behavior. "Removed for refactor" with no replacement = regression.
4. **Removal-direction silence is a red flag.** Net diff large-negative (lots removed, few added) → almost always
   dropped behavior. Per-kind expected shape is the baseline; deviations need explicit justification.
5. **A shared symbol's verification scope is its callers' suites, not the files you edited.** Refactoring a guard,
   helper, mixin, or base class that many callers depend on → run the full suite for every directory exercising those
   callers, at each refactor commit boundary. Targeted specs for the edited paths pass while a semantic inversion breaks
   siblings. Enumerate callers first (grep the symbol), then map them to suite directories — never infer scope from the
   diff's file list.

## Stage 0: Detect refactor kind

- Classify as extract-helper, move-file, rename, split-file, pure-rebase, inline-helper, or collapse/merge before
  auditing: kinds and expected diff shapes in [references/refactor-kinds.md](references/refactor-kinds.md).
- Diff doesn't match the kind's expected shape (e.g. "extract-helper" with a 200-line net-negative caller) → **stop and
  surface it** before continuing. The mismatch is the finding.
- Kind genuinely unclear → ask the user once. Don't guess: wrong classification produces the wrong checklist.

## Stage 1: Two-axis diff

Capture where the branch **came from** and where it lands **now**:

```bash
PR_NUM=$(gh pr view "${1:-}" --json number --jq .number 2>/dev/null \
         || gh pr view --json number --jq .number)
BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
git fetch origin "$BASE" --quiet

# Where the branch forked from
MERGE_BASE=$(git merge-base HEAD "origin/$BASE")

# Net diff against base (what reviewers see)
git diff -M "origin/$BASE..HEAD"           > /tmp/refactor-base.diff

# Net diff against fork point (what the branch did over its life)
git diff -M "$MERGE_BASE..HEAD"            > /tmp/refactor-mb.diff

# Per-file rename/move map
git diff -M --summary "origin/$BASE..HEAD" > /tmp/refactor-renames.txt
```

- Use `-M`: renamed files show as renames, not delete + add.
- Lines absent from both diffs but expected by the refactor's kind = strongest behavior-loss signal.

## Stage 2: Removed-line audit (per file)

- Walk every removed line in each modified file; classify as relocated, subsumed, intentionally removed, or suspicious.
  Checklist (env vars, fallback chains, rescue clauses, guards, tests, diagnostics, behavior narrowing) and
  stale-literal check: [references/removed-line-audit.md](references/removed-line-audit.md).
- A removed line the refactor's kind does NOT predict = **suspicious by default**.

## Stage 3: Source-of-truth compare

Read each touched file's base version side-by-side with HEAD:

```bash
for f in $(git diff --name-only "origin/$BASE..HEAD"); do
  echo "===== $f ====="
  git show "origin/$BASE:$f" 2>/dev/null > "/tmp/refactor-was-$f"
  diff -u "/tmp/refactor-was-$f" "$f" || true
done
```

Read for semantic divergence; ignore renames, reorderings, and formatting. Spot:

- Branches present on the base but absent on HEAD without a documented reason.
- Different default values for the same effective parameter.
- Different exception types raised for the same effective error.
- Different return shapes (e.g., `nil` vs raise) for the same effective failure.
- Tests on the base that exercise behavior the new shape no longer exercises.

Split into N children → build a **coverage map**: every functional concern in the source maps to one child; concerns
with no destination = findings.

## Stage 4: Surface findings

- Group by file and severity; present each with the finding block, then ask one finding at a time with the a/b/c/s
  prompt: [references/finding-templates.md](references/finding-templates.md).
- (b) Regression → draft a fix as a small commit on top of the current branch (do not amend mid-review). (c) → Stage
  3-style investigation on just that file. (s) → record the skip in the report.
- **All** findings confirmed intentional → refactor passes. Any regression survives → non-pass status; user can override
  but the report stands.

## Stage 5: Report

- Emit one block per file plus the summary (template in
  [references/finding-templates.md](references/finding-templates.md)).
- Make it paste-ready into the PR description under a `## Refactor audit` heading.

## Conflict-resolution audit (special case)

Run this extra pass after `wk-pr-update` or `wk-pr-resolve` resolved conflicts:

- Every file where `--theirs` or `--ours` was used wholesale (not a hand-merge) = **automatically suspicious** until
  audited.
- Flag pairs that crossed the conflict boundary together (e.g. `lib/X.rb` and `spec/X_spec.rb` both resolved with
  `--theirs`): the test moved with the code, so the suite stays green while paths from the *other* side are gone.
- Compare both files against the **other** side via `git show :2:<path>` (ours) and `git show :3:<path>` (theirs) before
  the resolution was committed when possible; otherwise against the base branch.

## Coordination with other skills

- **`wk-pr-update`** invokes `wk-refactor` after every successful rebase / patch-replay before reporting integration
  complete.
- **`wk-pr-resolve`** invokes it after resolving any conflicts in Step 2 before triaging review feedback.
- **`wk-pr`** invokes it before `gh pr ready` when the diff is movement-dominated (renames > 50% of touched files, or
  net-zero LOC across many files).
- **`wk-workflow`** Phase 5.5 (Adversarial Review) treats a `wk-refactor` PASS as a precondition for adversarial review
  when the task was framed as a refactor.
- **`wk-testing-skeleton`** writes tests for new behavior; this skill protects existing behavior during reshape.

## Post-Completion

Invoke `wk-learn refactor`.
