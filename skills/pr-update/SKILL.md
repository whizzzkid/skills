---
name: wk-pr-update
description: >-
  Update a PR branch with the latest changes from its base branch. Picks
  the right strategy automatically — rebase when the branch has <5 commits
  ahead, patch-replay (diff against old base, apply onto new base) when it
  has more. Resolves conflicts interactively, re-validates the work after
  integration (tests + build), syncs the PR description via `wk-commit`'s
  PR Sync rule, and force-with-lease pushes. Use when asked to "update
  PR", "rebase on main", "sync with base", "pull in latest from main",
  or after CI surfaces a base-branch conflict.
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
  version: '2026.05.12-225934'
  internal: false
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Update

Bring a PR branch up to date with its base, with the right integration
strategy for the branch's size, conflicts resolved interactively, and
the work re-validated after integration.

```
Pre-flight ──► Detect base ──► Choose strategy
                                  ├─ <5 commits → rebase
                                  └─ ≥5 commits → patch-replay
              Resolve conflicts ──► Re-validate ──► Sync PR ──► Push
```

---

## Hard Rules

1. **Never run on a dirty tree.** Stash or commit first; pre-flight
   refuses to start otherwise.
2. **Never force-push without `--force-with-lease`.** `--force` alone
   loses concurrent contributor work; lease aborts the push if the
   remote moved.
3. **Never silently drop commits.** Patch-replay must reproduce the
   branch's net diff exactly; if conflict resolution alters the diff,
   surface it before pushing.
4. **Never push without re-validation.** The branch must build and pass
   tests after integration, not before.
5. **Never skip PR description sync.** A push that updates the branch
   but leaves a stale PR body violates `wk-commit`'s PR Sync HARD RULE.

---

## Stage 0: Pre-flight

Confirm the work environment is safe to mutate.

```bash
# Must be in a git repo, with a current branch that isn't the base
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Reject dirty tree
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is dirty. Stash or commit before running."
  exit 1
fi

# Capture starting SHA for the safety net
START_SHA=$(git rev-parse HEAD)
```

If the tree is dirty, ask:

> "Working tree has uncommitted changes. (a) stash → run → unstash,
> (b) commit them first via `wk-commit`, (c) abort."

Auto mode defaults to **(c) abort** — picking (a) or (b) on the
user's behalf is the kind of mutation auto mode should not make
silently.

---

## Stage 1: Detect base, fetch, compute commit count

The base branch is given as an argument or inferred:

```bash
# 1. Argument > 2. PR base > 3. repo default
BASE="${1:-$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null \
            || git symbolic-ref refs/remotes/origin/HEAD --short \
                | sed 's@^origin/@@')}"

# Base may have been merged and deleted; re-detect if fetch fails
if ! git fetch origin "$BASE" 2>/dev/null; then
  BASE=$(gh pr view --json baseRefName --jq .baseRefName)
  git fetch origin "$BASE"
fi
BASE_REF="origin/$BASE"

# Commits the branch is ahead of the base
AHEAD=$(git rev-list --count "$BASE_REF..HEAD")
BEHIND=$(git rev-list --count "HEAD..$BASE_REF")

echo "Branch $BRANCH is $AHEAD ahead, $BEHIND behind $BASE."
```

If `$BEHIND` is 0, the branch is already up to date — exit early with
a one-line note. Otherwise continue to strategy selection.

---

## Stage 2: Choose integration strategy

| `$AHEAD` | Strategy | Why |
|----------|----------|-----|
| **< 5** | Rebase | Small commit count → linear history is cheap to preserve; reviewers can read each commit independently. |
| **≥ 5** | Patch-replay | Large commit count → rebasing N commits is N conflict-resolutions; one patch is one. Commit messages are reconstructed from the squashed subject + a body listing the original SHAs for traceability. |

The threshold is a heuristic, not a contract. The user can override
once at run time:

> "Branch has {AHEAD} commits ahead — picking {strategy}. Override?
> (a) keep {strategy}, (b) force rebase, (c) force patch-replay,
> (d) abort."

Auto mode picks the heuristic without prompting.

---

## Stage 3a: Rebase strategy (`$AHEAD < 5`)

```bash
git rebase "$BASE_REF"
```

If the rebase reports conflicts, drop into the **conflict
resolution loop** (Stage 4). On clean rebase, jump to Stage 5.

If the rebase introduces test failures or behavioral regressions
(detected in Stage 5), the safety net `git reset --hard $START_SHA`
restores the pre-rebase state — see Stage 6 abort path.

---

## Stage 3b: Patch-replay strategy (`$AHEAD ≥ 5`)

The goal is to land the branch's **net diff** on top of the new base
as a single integration commit, while preserving traceability to the
original commits.

```bash
# 1. Snapshot the net diff against the OLD base (the merge-base, not the
#    new tip — patch-replay is "what did this branch change", not "what
#    happened on main since this branch forked").
OLD_BASE=$(git merge-base HEAD "$BASE_REF")
git diff "$OLD_BASE..HEAD" > /tmp/pr-update-$$.patch

# 2. Capture the original commit log for the integration commit body
git log --reverse --format='- %h %s' "$OLD_BASE..HEAD" > /tmp/pr-update-$$.log

# 3. Reset the branch to the new base
git reset --hard "$BASE_REF"

# 4. Apply the patch
if ! git apply --3way /tmp/pr-update-$$.patch; then
  # Conflicts — fall into the resolution loop with patch context
  echo "Patch did not apply cleanly. Resolving conflicts..."
fi
```

After patch application (clean or post-conflict-resolution), produce
**one** integration commit that names the squashed subject and lists
the original commits in the body for git-log traceability:

```bash
git add -A
git commit -S -m "$(cat <<EOF
<conventional-subject>: <emoji> <one-line summary of the net change>

Squashed via wk-pr-update onto $BASE @ $(git rev-parse --short "$BASE_REF").

Original commits:
$(cat /tmp/pr-update-$$.log)

Co-Authored-By: <agent>
EOF
)"
```

The commit subject MUST follow `wk-commit`'s conventional format with
a single emoji classifier. If the original branch had a clear theme,
use that theme; if mixed, use 🤖 (the "no single emoji fits"
fallback).

Patch-replay rewrites the branch to a single commit. **The original
commits are lost from the branch's git log** — they live only in the
integration commit's body. This is the deliberate cost of the
strategy; the user accepted it by having ≥5 commits and not picking
"force rebase."

---

## Stage 4: Conflict resolution loop

Whether rebasing or patch-applying, conflicts surface the same way —
files with `<<<<<<<` markers, `git status` listing "both modified."

```bash
git status --short | grep '^UU\|^AA\|^DD'
```

For each conflicted file:

1. **Read** both sides (`<<<<<<< HEAD` is the base; `>>>>>>>
   <branch>` is the branch's version during rebase, or the patch
   during patch-replay).
2. **Decide** the resolution. Prefer keeping the branch's intent
   (the work being integrated is the reason the PR exists) unless
   the base change supersedes it (e.g., the file was renamed on
   base; resolution is to apply the branch's edits to the new
   filename).
3. **Verify** the resolved file makes sense — open it, scan for
   stray markers, run a quick syntax check (`node --check`,
   `python -m py_compile`, `cargo check`, etc. — whatever is cheap
   for the language).
4. **Stage** the resolution: `git add <file>`.

Auto mode resolves only **trivial** conflicts (one side adds an
import the other doesn't touch; whitespace-only divergence;
non-overlapping additions). Anything semantically meaningful pauses
and asks:

> "Conflict in `{path}`:
>   {3-line excerpt of the conflict region}
> (a) keep branch's version  (b) keep base's version
> (c) describe a manual merge  (d) abort"

After all files are resolved:

- **Rebase:** `git rebase --continue`. Loop if more conflicts.
- **Patch-replay:** the working tree now has a clean diff; proceed
  to the integration commit (Stage 3b step 4).

If the conflicts are too tangled to resolve cleanly, **abort** and
restore the starting state:

```bash
git rebase --abort 2>/dev/null
git reset --hard "$START_SHA"
```

Tell the user: "Conflicts could not be resolved automatically. The
branch is back to its starting state. Resolve manually via `git
rebase $BASE_REF` and re-run."

---

## Stage 5: Re-validate

The branch now has the base's changes integrated; the work must
still build and pass tests **after** that integration. Pre-integration
validation does not transfer.

### Dependency install pre-check

Integration may invalidate the local dependency cache. Before
running the test suite, diff the project's dependency lockfile
between the pre-integration base and the post-integration base.
If it changed, install dependencies first — otherwise a
"missing dependency" error masquerades as a test regression.

```bash
# Example signals — extend per project package manager
for lockfile in Gemfile.lock package-lock.json yarn.lock pnpm-lock.yaml \
                Cargo.lock poetry.lock uv.lock go.sum; do
  [ -f "$lockfile" ] || continue
  if ! git diff --quiet "$START_SHA"..HEAD -- "$lockfile"; then
    echo "Lockfile changed: $lockfile — install before validating."
    # Run the project's install command (bundle install, npm ci, cargo fetch, etc.)
    break
  fi
done
```

Detect the project's test command from these signals (first hit
wins):

- `package.json` `scripts.test` → `npm test`
- `pyproject.toml` `[tool.pytest]` / `pytest.ini` → `pytest`
- `Cargo.toml` → `cargo test`
- `Gemfile` + `spec/` → `bundle exec rspec`
- `go.mod` → `go test ./...`
- `.buildkite/` or CI config naming a test step → run that step locally
  via the project's task runner if available

Run the test suite and the type/lint checks if cheap:

```bash
# Example for a Node project
npm test 2>&1 | tail -20
npm run typecheck 2>&1 | tail -10  # if defined
```

| Outcome | Action |
|---------|--------|
| All green | Proceed to Stage 6 |
| Tests fail in code the integration touched | Treat as a real regression — diagnose, fix on the integrated branch, re-validate. Do not push a known-broken integration. |
| Tests fail in code unrelated to the integration | Almost always means the base introduced the failure — re-run on `$BASE_REF` to confirm; if reproducible there, surface to the user but do not block the integration push. |
| No test command detected | Note the gap, surface it to the user, proceed (the user accepted the lack of automated coverage when they ran the skill) |

If validation surfaces a regression and the user says "abort":

```bash
git reset --hard "$START_SHA"
```

The branch returns to its pre-integration state. The user can retry
after fixing whatever made integration produce broken output.

### Behavior-preservation check

Tests passing is necessary but **not sufficient** — when both production
code and its spec are picked from the same side of a conflict, the
regression is internally consistent and CI does not catch it.

For every file touched by the integration, diff the integrated result
against the pre-integration base:

```bash
git diff "$START_SHA"..HEAD -- <file>
```

Scan for removed lines in these high-risk categories:

| Category | Examples |
|----------|---------|
| Environment lookups | `ENV.fetch`, `process.env`, `os.environ` |
| Fallback chains | `if x.nil?`, `x || default`, `?? fallback` |
| Error handling | `rescue`, `catch`, `try/except`, `.on_error` |
| Guards / early returns | `unless`, `return if`, `if !x` |
| Spec coverage | removed `it` / `test` / `describe` blocks |

If a removed line's behavior appears nowhere else in the diff, surface
it:

> "Line removed: `{line}` — behavior `{description}` now has no owner.
> Was this intentional?"

Do not push if the user has not answered. A pure integration's net diff
should be narrow; large unexplained deletions warrant line-by-line review,
not just a passing test suite.

---

## Stage 6: Sync PR description and push

The branch is now correct; align the PR with reality.

### Sync the PR

Invoke the PR Sync flow from `wk-commit` (HARD RULE: post-push, the
PR title and body must reflect the post-push branch state). For
patch-replay specifically, also update:

- The PR body's commit list / "What's included" section, if present
  — the branch is now one squashed commit, not N.
- Metadata lines (issue-closing annotations, co-author trailers, automation blocks,
  ticked test-plan checkboxes) — **HARD RULE:** preserve verbatim per
  `skills/pr/references/pr-description-metadata.md`.

### Push

```bash
git push --force-with-lease
```

`--force-with-lease` aborts if the remote has commits the local
branch doesn't know about (someone else pushed concurrently). On
abort, fetch and re-run the skill — never escalate to `--force`.

If there is no PR yet (skill ran on a local branch), skip the sync
step and stop after the validated rebase/replay — the user wanted
"update", not "create".

---

## Stage 7: Final report

One line per stage actually run:

> "Updated `feat/foo` onto `origin/main`:
> - strategy: patch-replay (7 commits → 1 integration commit)
> - conflicts: 2 resolved (auto: 1, asked: 1)
> - validation: 142/142 tests passing, typecheck clean
> - PR #NNN synced and pushed"

If a stage was skipped (no PR, no test command, etc.), say so on
its line — don't omit the line.

---

## Coordination with other skills

- **`wk-workflow`** — this skill is a *tool* used inside Phase 5/6.
  When `wk-workflow` Phase 6's CI fix loop diagnoses a "branch is
  behind base" failure, it should invoke `wk-pr-update` rather than
  reinventing the rebase logic.
- **`wk-pr`** — when `wk-pr` is updating an existing PR (not
  creating one) and the branch is behind base, it should invoke
  `wk-pr-update` first, then resume the rest of its post-creation
  workflow.
- **`wk-commit`** — the integration commit (patch-replay) and any
  conflict-resolution commits MUST follow `wk-commit`'s rules:
  signed, conventional format, single emoji, PR Sync after push.

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

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-update`).
