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
  version: "2026.10.09-171327"
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

- Refactor preserves behavior → only shape changes.
- Passing tests + clean lints prove **new code paths** work → say nothing about whether **paths that should still exist** survived.
- This skill = the gate that catches dropped behavior before "ready for review."

```
Detect kind ──► Two-axis diff ──► Removed-line audit
  (extract /         (merge-base       (per-file checklist:
   move /            and base)          env, fallbacks,
   rename /                             rescues, guards,
   split /                              comments+branches,
   pure-rebase)                         deleted tests)
                                              │
                                              ▼
                                    Source-of-truth compare
                                              │
                                              ▼
                                    Surface findings ──► confirm or fix
```

---

## When this fires

| Trigger | Required |
|---------|----------|
| `wk-pr-update` finishes a rebase or patch-replay | Yes |
| `wk-pr-resolve` resolves any conflict | Yes |
| Agent has just extracted a helper / moved a file / renamed a symbol / split a module | Yes |
| Before any "ready for review" / `gh pr ready` on a PR whose diff is movement-dominated | Yes |
| User invokes `/wk-refactor` or `/wk-refactor <pr>` | Manual |

- Never blocks integration → produces findings the user must acknowledge.
- **Do not** substitute the lint/test gate → those verify new code; this verifies the old code isn't gone.

---

## Hard Rules

1. **Tests passing is not preservation.** Suite covers paths that *exist*; preservation requires verifying paths that *should still exist* are still there. Never claim refactor correctness on a green suite alone.
2. **Conflict resolution by `--theirs` / `--ours` is a red flag.** Picking one of two valid functional paths wholesale → internally-consistent but externally-regressed code. Audit every `--theirs`/`--ours` resolution for behavior loss before this skill is satisfied.
3. **A pure refactor changes which file behavior lives in, not which behavior exists.** Disappeared tests must be either (a) explicitly out-of-scope (PR description says so), or (b) renamed/moved to a new test file asserting the same behavior. "Removed for refactor" with no replacement = regression.
4. **Removal-direction silence is a red flag.** Net diff large-negative (lots removed, few added) → almost always dropped behavior. Per-kind expected shape below is the baseline; deviations need explicit justification.
5. **A shared symbol's verification scope is its callers' suites, not the files you edited.** Refactoring a guard, helper, mixin, or base class that many callers depend on → run the full suite for every directory exercising those callers, at each refactor commit boundary. Targeted specs for the edited paths pass while a semantic inversion breaks siblings; the narrower run is what lets the regression reach CI. Enumerate callers first (grep the symbol), then map them to suite directories — never infer scope from the diff's file list.

---

## Stage 0: Detect refactor kind

Classify before auditing → different kinds have different expected diff shapes; wrong-shape signal = fastest detector for behavior loss.

| Kind | Detect via | Expected diff shape |
|------|------------|---------------------|
| **extract-helper** | New file/function appears; existing call site shrinks | Caller: roughly net-zero LOC (inline code → one call). Helper file: net-positive matching what was removed. |
| **move-file** | `git diff -M` reports rename/move; content nearly unchanged | Net-zero overall; rename detection should flag it. |
| **rename** (symbol or path) | One identifier replaced by another across many files | Strictly substitution; no logic changes. |
| **split-file** | One file replaced by N smaller files | Source net-removed; new files net-added; sum ≈ 0. |
| **pure-rebase** | Same commits, different parent | Diff against new parent equals diff against old parent (modulo conflict resolutions). |
| **inline-helper** | Helper file removed; call sites grow | Inverse of extract-helper. |
| **collapse / merge files** | Two+ files become one | Sources net-removed; target net-added; sum ≈ 0. |

- Actual diff doesn't match the kind's expected shape (e.g. "extract-helper" with a 200-line net-negative caller) → **stop and surface it** before continuing the audit. The mismatch is the finding.
- Kind genuinely unclear → ask the user once. Don't guess — wrong classification produces the wrong audit checklist.

---

## Stage 1: Two-axis diff

Refactors live between two reference points — where the branch **came from** and where it lands **now**. Capture both:

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

- Use `-M` → renamed files identified as renames, not delete + add.
- Two diffs together reveal divergence: lines absent from both diffs but expected by the refactor's kind = strongest behavior-loss signal.

---

## Stage 2: Removed-line audit (per file)

For each modified file, walk every removed line and classify as relocated,
subsumed, intentionally removed, or suspicious. See
[references/removed-line-audit.md](references/removed-line-audit.md) for the
full checklist (env vars, fallback chains, rescue clauses, guards, tests,
diagnostics, behavior narrowing) and the stale-literal check.

A removed line the refactor's kind does NOT predict = **suspicious by default**.

---

## Stage 3: Source-of-truth compare

For each touched file, fetch the pre-refactor version from the base branch and read side-by-side with the post-refactor file:

```bash
for f in $(git diff --name-only "origin/$BASE..HEAD"); do
  echo "===== $f ====="
  git show "origin/$BASE:$f" 2>/dev/null > "/tmp/refactor-was-$f"
  diff -u "/tmp/refactor-was-$f" "$f" || true
done
```

Read the side-by-side **for semantic divergence**, not syntactic delta. Renames, reorderings, pure formatting = noise. Spot:

- Branches present on the base but absent on HEAD without a
  documented reason.
- Different default values for the same effective parameter.
- Different exception types raised for the same effective error.
- Different return shapes (e.g., `nil` vs raise) for the same
  effective failure.
- Tests on the base that exercise behavior the new shape no longer
  exercises.

Split into N children → build a **coverage map**: every functional concern in the source must map to one child. Concerns with no destination = findings.

---

## Stage 4: Surface findings

Group findings by file and by severity. For each, present:

```
{path} — {kind: relocated / subsumed / suspicious}
  Removed:  {line excerpt with line number from base}
  Replaces: {pointer to relocation, or "—"}
  Concern:  {what behavior may have been dropped}
  Verify:   {one concrete check the user should run, or auto-run}
```

Then ask, one finding at a time:

> "**Finding {n}/{total}** — {summary}.
>
> **(a)** Confirmed intentional — proceed
> **(b)** Regression — propose a fix
> **(c)** Need more info — investigate further
> **(s)** Skip
>
> Reply `a` / `b` / `c` / `s`."

- (b) → draft a fix as a small commit on top of the current branch (do not amend mid-review).
- (c) → drop into Stage 3-style investigation on just that file.
- (s) → record the skip in the report.

- **All** findings confirmed intentional → refactor passes.
- Any regression survives → non-pass status; user can override but the report stands.

---

## Stage 5: Report

One block per file, plus a summary:

```
Refactor kind: <classification>
Diff shape: matches | deviates (<reason>)
Files audited: <count>
Findings: <count> total ({a} confirmed, {b} fixed, {c} skipped, {open} remaining)
Status: PASS | REGRESSIONS REMAINING

Per-file:
- <path>: <one-line per finding with status>
```

Report is paste-ready into the PR description (under a `## Refactor audit` heading) so reviewers see what was checked.

---

## Conflict-resolution audit (special case)

Fires after `wk-pr-update` or `wk-pr-resolve` resolved conflicts → run an additional pass.

- Every file where `--theirs` or `--ours` was used wholesale (not a hand-merge) = **automatically suspicious** until audited.
- Flag pairs of files that crossed the conflict boundary together: `lib/X.rb` resolved with `--theirs` and `spec/X_spec.rb` resolved with `--theirs` (or vice versa) → implementation and its test moved together. Failure mode: suite stays green because the test moved with the code, hiding that paths from the *other* side are gone.
- Compare both files against the **other** side via `git show :2:<path>` (ours) and `git show :3:<path>` (theirs) before the resolution was committed when possible; otherwise compare against the base branch.

---

## Coordination with other skills

- **`wk-pr-update`** invokes `wk-refactor` after every successful
  rebase / patch-replay before reporting integration as complete.
- **`wk-pr-resolve`** invokes `wk-refactor` after resolving any
  conflicts in Step 2 before triaging review feedback.
- **`wk-pr`** invokes `wk-refactor` before `gh pr ready` when the
  branch's diff is movement-dominated (renames > 50% of touched
  files, or net-zero LOC across many files).
- **`wk-workflow`** Phase 5.5 (Adversarial Review) treats a `wk-refactor`
  PASS as a precondition for the adversarial code review when the
  task was framed as a refactor.
- **`wk-testing-skeleton`** complements: it writes tests for new
  behavior; this skill protects existing behavior from disappearing
  during reshape. Together they cover both directions.

---

## Post-Completion

Invoke `wk-learn refactor`.
