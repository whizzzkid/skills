---
name: wk-pr-takeover
description: >-
  Take over a PR currently being worked on by someone else. Two modes: overwrite
  (default, checks out existing branch and continues as primary author) and stack
  (creates a new branch on top, leaving the original untouched). Runs the full
  wk-workflow. Use when asked to "take over", "continue", "pick up", "inherit",
  or "finish someone else's PR".
argument-hint: '<pr-number-or-url> [--stack]'
allowed-tools:
  - "Bash(git:*)"
  - "Bash(gh pr:*)"
  - "Bash(gh api:*)"
  - "Bash(gh repo:*)"
  - "Bash(npx skills:*)"
  - Read
  - Write
  - Edit
  - AskUserQuestion
  - Skill
model: sonnet
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
env-vars:
  - WK_SKILLS_EMPLOYEE_EMAIL
metadata:
  author: whizzzkid
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR Takeover

Take over an in-flight PR — understand existing work, join as co-author, drive to
completion via `wk-workflow`.

## Hard Rules

0. **Never self-approve.** Both authors are PR authors post-takeover → request peer review.
1. **Co-authorship on every commit** via `Co-Authored-By` trailers.
2. **Scope explosion → stack.** Takeover changes >30% of original diff → auto-switch to stack mode.
3. **Full `wk-workflow` always runs.** No phase skipping.
4. **PR description reflects combined work.** Preserve metadata per `skills/pr/references/pr-description-metadata.md`.

## Step 1: Parse Arguments

`wk-pr-takeover <pr-number-or-url> [--stack]`

- `--stack` → stack mode; else overwrite mode.
- No argument → infer from current branch: `gh pr view --json number --jq .number 2>/dev/null`. Found → confirm; not found → ask.

## Step 2: Fetch PR Context

`gh pr view "$PR_NUMBER" --json number,title,body,headRefName,baseRefName,author,state,isDraft,reviews,comments`
plus `gh api` for review/timeline comments, `gh pr diff "$PR_NUMBER" | head -500`.
Summarize: goal, code written, review feedback, unresolved threads.

## Step 3: Check Out the Branch

### Revive precheck — closed PR with deleted base

`state: CLOSED` + `git ls-remote --heads origin "$BASE_BRANCH"` empty → no in-place revive. Recovery: rebase onto default branch, open new PR, cross-link.

### Overwrite Mode (default)

`gh pr checkout "$PR_NUMBER"` → verify clean + up to date. Conflicts → `wk-pr-update`.

### Stack Mode

```bash
HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName -q .headRefName)
git fetch origin "$HEAD_BRANCH"
git checkout -b "${HEAD_BRANCH}-takeover" "origin/$HEAD_BRANCH"
```

Stacked on draft → surface options: (A) stack anyway, (B) retarget to default (auto-mode default), (C) cancel.

## Step 4: Orient to Existing Work

Read all touched files. Identify: patterns, incomplete sections (TODO/FIXME),
test coverage. Run test suite as baseline per [test-runner examples](references/test-runner-examples.md).
Prose/config diff → gate-preservation audit instead.

## Step 5: Establish Co-Authorship

`git log --format="%an <%ae>" $(git merge-base HEAD origin/$BASE)..HEAD | sort -u`
Sole author is user → skip. Otherwise: `export WK_CO_AUTHOR="$ORIGINAL_AUTHOR"`.

## Step 6: Plan Remaining Work

Task list from Step 4: unresolved feedback, incomplete code, missing tests,
pre-existing failures. >30% scope in overwrite mode → switch to stack mode.

## Step 7: Run `wk-workflow`

`Skill("wk-workflow")` — Plan from existing work, implement with `$WK_CO_AUTHOR`,
test both original + new code, adversarial review covers full diff, self-review
posts comments only (never approve), retro with `wk-learn pr-takeover`.

## Step 8: Update or Create PR

**Overwrite:** `gh pr edit` with combined description + takeover note; `git push origin HEAD`.

**Stack:** `gh pr create --draft --base "$HEAD_BRANCH"` with stacked-on reference;
update original PR to note continuation.

## Step 9: Self-Review

`Skill("wk-self-review")` — post comments only, never approve.

## Step 10: Handoff Summary

Post PR comment: mode, pre-existing failures, work completed, deferred items,
stacked PR reference. `Co-Authored-By` email per wk-commit's HARD RULE: user =
`$WK_SKILLS_EMPLOYEE_EMAIL` (unset → STOP); original author = `<id>+<login>@users.noreply.github.com` (never guess `<login>@<domain>`).

---

## Post-Completion

Invoke `wk-learn pr-takeover`.
