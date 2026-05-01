---
name: wk:pr
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
  - "Bash(gh api repos:*)"
  - Read
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.01-073751'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR

Create and manage GitHub pull requests with draft mode, stacking support, and
a post-creation workflow that ensures quality before marking ready for review.

## Hard Rules

1. **Preserve PR body metadata across description rewrites.** When updating a
   PR description with `gh pr edit`, always read the current body first and
   carry forward these metadata lines into the new body:
   - `Closes #N` / `Fixes #N` / `Resolves #N` — auto-close annotations
   - `Co-authored-by:` lines — attribution
   - Automation-generated blocks: `**Build:** [...]` links, `<details>`
     context blocks, generator footer lines
   
   These are metadata, not prose — they survive across description rewrites.
   `gh pr edit --body-file` replaces the entire body with no merge. Silently
   dropping `Closes #N` means the linked issue stays open after merge.

## Step 1: Assess Scope

### Detect the true base branch (run unconditionally)

Before measuring scope, detect the branch's actual fork point.
Assuming the default branch is the base produces a PR with
unrelated commits in the diff (from a parent in-flight branch),
CI failures against the wrong target, and a silent stacked-PR
that lacks the `[Part X/Y]` annotation.

Compute the merge-base distance between the current branch and
every candidate base — the default branch plus every open PR's
`headRefName` (your own and others'). The candidate with the
**closest** merge-base (smallest commit distance) is the real
base; ties prefer the default branch.

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null \
                 | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}

# Candidate set: default + every open PR's head ref
CANDIDATES=$(
  { echo "$DEFAULT_BRANCH"
    gh pr list --state open --json headRefName --jq '.[].headRefName'
  } | sort -u
)

BEST_BASE="$DEFAULT_BRANCH"
BEST_DIST=999999
HEAD_SHA=$(git rev-parse HEAD)
for CAND in $CANDIDATES; do
  git fetch origin "$CAND" --quiet 2>/dev/null || continue
  MB=$(git merge-base "$HEAD_SHA" "origin/$CAND" 2>/dev/null) || continue
  [ "$MB" = "$HEAD_SHA" ] && continue   # candidate is downstream of HEAD; not a base
  DIST=$(git rev-list --count "$MB..$HEAD_SHA")
  if [ "$DIST" -lt "$BEST_DIST" ] || \
     { [ "$DIST" -eq "$BEST_DIST" ] && [ "$CAND" = "$DEFAULT_BRANCH" ]; }; then
    BEST_DIST=$DIST
    BEST_BASE=$CAND
  fi
done
```

If `$BEST_BASE` differs from `$DEFAULT_BRANCH`, surface to the user
before doing anything else — silent mis-basing is hard to recover
from once CI has run and reviewers have started reading:

> "This branch was forked from `{BEST_BASE}` (open PR #{N}), not
> `{DEFAULT_BRANCH}`. Choose:
>
> **A)** Create this PR with `--base {BEST_BASE}` and treat it as
> stacked (adds `[Part X/Y]` and `## Stack` to the body).
> **B)** Rebase onto `{DEFAULT_BRANCH}` first, then create against
> the default base.
> **C)** Cancel.
>
> Reply `A` / `B` / `C`."

Auto mode picks **A** — preserving the existing fork point is
non-destructive and the stacked-PR convention covers the
metadata. Picking **B** invokes `wk:pr-update` to rebase before
proceeding.

### Measure scope against the resolved base

Use `$BEST_BASE` for both the scope diff and the eventual
`gh pr create --base` flag — measuring against the wrong base
inflates the LOC and breaks the stacking decision below.

```bash
git diff "$BEST_BASE...HEAD" --stat
git diff "$BEST_BASE...HEAD" --shortstat
```

- If the diff exceeds ~30 lines, ask the user if they want to split
  further via `wk:pr-break` (in addition to any stacking implied
  by `$BEST_BASE`).
- If borderline or unclear, ask the user's preference.
- Pass `$BEST_BASE` through to Step 2 — never re-detect or default
  back to `main`.

## Step 2: Create Draft PR

**Always create PRs in draft mode** (`--draft` flag). Never create a non-draft
PR unless the user explicitly asks.

### Resolve PR Body Template

Before composing the PR body, check the target repository for a GitHub PR
template. Search these paths in order and use the first match:

```bash
TEMPLATE_FILE=""
for tpl in \
  .github/pull_request_template.md \
  .github/PULL_REQUEST_TEMPLATE.md \
  pull_request_template.md \
  PULL_REQUEST_TEMPLATE.md; do
  [ -f "$tpl" ] && TEMPLATE_FILE="$tpl" && break
done

# If no single file matched, check the multi-template directory
if [ -z "$TEMPLATE_FILE" ]; then
  for d in .github/PULL_REQUEST_TEMPLATE .github/pull_request_template; do
    [ -d "$d" ] && ls "$d"/*.md && break
  done
fi
```

| Scenario | Action |
|----------|--------|
| Single template file found | Read it and use as the PR body structure |
| Template directory found | List the `.md` files, ask the user which to use, then read it |
| No template found | Fall back to the hardcoded templates below |

When using a repo template:

- **Populate every section** with real content derived from the diff and commit
  history. Do not leave placeholder text or unfilled sections.
- **Preserve the template's structure** — keep its headings, order, and any
  boilerplate (checkboxes, legal text, etc.) intact.
- **For stacked PRs**, append a `## Stack` section after the summary (or first
  heading) if the template does not already include one.
- If the template contains sections irrelevant to the current changes, fill
  them with "N/A" or a brief note explaining why they don't apply.

### Simple PR (fallback — no repo template found)

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

`--base "$BEST_BASE"` MUST be present on every `gh pr create`
call — never omit it and rely on the default. The base resolved
in Step 1 is authoritative; defaulting silently re-introduces
the mis-basing failure mode.

PR titles use the same conventional commit + emoji scheme as commit messages.

### Stacked PR (fallback — no repo template found)

When splitting work into stacked PRs:

- Append `[Part X/Y]` at the end of the PR title
- Base each PR on the previous one: `--base previous-branch`
- Each PR must pass CI in isolation — no forward dependencies
- Example: `feat(auth): ✨ add OAuth2 login [Part 1/3]`

```bash
gh pr create --draft --base previous-branch \
  --title "feat(scope): ✨ description [Part X/Y]" \
  --body "$(cat <<'EOF'
## Summary
- What changed and why

## Stack
- Part 1: #PR_NUMBER (merged/open)
- **Part 2: this PR**
- Part 3: pending

## Test plan
- [ ] How to verify the changes

EOF
)"
```

When a repo template is used for a stacked PR, use the template as the body
structure and inject the `## Stack` section listing all parts with PR numbers
and status, following the same format shown above.

## Step 3: Post-Creation Workflow

After the draft PR is created (or after pushing new commits to an existing PR):

1. **Update PR description** — Review the existing description to ensure it
   still covers all changes. If it has drifted, update with `gh pr edit`.
   **Before overwriting**, read the current body and extract metadata lines
   (see Hard Rule 1). Re-insert them into the updated body.
2. **Poll CI** — Launch a background polling job (using the pass-the-build
   agent if available) to wait for all build steps to pass. Do not proceed
   while CI is failing.

## Step 4: Once CI is Green

1. **Invoke `wk:self-review`** to post design-decision comments on the PR.
   This documents non-obvious choices and critical context for human reviewers.

2. **Address automated review feedback** — Fetch existing review comments from
   automated tools:

   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   gh pr reviews
   ```

   Present these as a numbered list with a suggested fix for each. Ask the
   user: "How would you like to handle these automated review comments?"
   Wait for the user's response before proceeding.

## Step 5: Mark Ready

After the self-review is posted and automated feedback is addressed:

```bash
gh pr ready
```

Confirm to the user:
> "PR #{number} is marked ready for review: {url}"

## Step 6: Session Retro

After the PR is marked ready, invoke `wk:retro` to capture session learnings.
This retrospective reviews what went well, what was corrected, and promotes
actionable lessons to the appropriate project files.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "create a PR" | Full workflow: draft → CI → self-review → ready → retro |
| "stack this PR" | Stacked PR with `[Part X/Y]` and `--base` |
| "mark PR ready" | Skip to step 5 |
| New commits pushed | Re-run from step 3 (update description, re-poll CI) |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote

---

## Post-Completion

Invoke `wk:learn` with this skill's short name as the argument (e.g., `wk:learn pr`).
