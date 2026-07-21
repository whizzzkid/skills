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
  version: '2026.07.21-191914'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# PR Takeover

Take over an in-flight PR from another author — understand work done so far, join
as co-author, drive to completion via full `wk-workflow`.

## Hard Rules

0. **Never approve your own work.** Both user and original author are PR authors
   after takeover → user must not self-approve. CI requires approval → request a
   peer review.
1. **Preserve co-authorship.** Every new commit adds both original author and
   user via `Co-Authored-By` trailers.
2. **Scope explosion → stacked PR.** Takeover changes exceed ~30% of original
   PR's line-count diff → auto-switch to `stack` mode for new work; do not expand
   the existing PR.
3. **Full workflow always runs.** `wk-workflow` governs all implementation work
   regardless of mode. Skipping phases not permitted.
4. **PR description reflects new reality.** After any substantive change → update
   PR body to combined work (original scope + takeover additions). Preserve all
   metadata lines per `skills/pr/references/pr-description-metadata.md`.

---

## Step 1: Parse Arguments

Accept: `wk-pr-takeover <pr-number-or-url> [--stack]`

- `--stack` present → **stack mode** (create new branch on top).
- Else → **overwrite mode** (continue on existing branch).
- No PR argument → infer target from current branch before prompting; fall
  through to prompt only when none found:

  ```bash
  PR_NUMBER=$(gh pr view --json number --jq .number 2>/dev/null)
  ```

  - PR found → confirm: "Taking over PR #N (<title>) on the current branch —
    continue?"
  - No PR resolves → ask "Which PR are you taking over? Provide a number or URL."

```bash
# Resolve PR number from an explicit URL/number argument
PR_URL="$1"
PR_NUMBER=$(echo "$PR_URL" | grep -oE '[0-9]+$')
```

---

## Step 2: Fetch PR Context

Pull full metadata for the target PR.

```bash
gh pr view "$PR_NUMBER" \
  --json number,title,body,headRefName,baseRefName,author,state,isDraft,reviews,comments \
  --jq '{
    number: .number,
    title: .title,
    body: .body,
    head: .headRefName,
    base: .baseRefName,
    author: (.author.login + " <" + .author.email + ">"),
    state: .state,
    isDraft: .isDraft
  }'
```

Fetch review + timeline comments → understand prior discussion:

```bash
gh api "repos/{owner}/{repo}/pulls/$PR_NUMBER/comments" \
  --jq '[.[] | {author: .user.login, body: .body, path: .path, line: .line}]'

gh api "repos/{owner}/{repo}/issues/$PR_NUMBER/comments" \
  --jq '[.[] | {author: .user.login, body: .body}]'
```

Read the diff → understand scope of work completed:

```bash
gh pr diff "$PR_NUMBER" | head -500
```

Summarize internally:
- Original author's goal (title + body)
- Code written (diff)
- Review feedback (comments)
- Unresolved threads

---

## Step 3: Check Out the Branch

### Revive precheck — closed PR whose base was merged + deleted

- A PR auto-closes when its base branch is squash-merged into the default branch
  and deleted. GitHub then forbids **both** reopen and base-retarget on it.
- Detect before any checkout:

  ```bash
  gh pr view "$PR_NUMBER" --json state,baseRefName
  git ls-remote --heads origin "$BASE_BRANCH"   # empty output = base ref gone
  ```

- `state: CLOSED` + empty `ls-remote` → do NOT `gh pr reopen` (returns
  `Could not open the pull request`) or `gh pr edit --base` (returns
  `GraphQL: Cannot change the base branch of a closed pull request`). There is
  no in-place revive.
- Recovery — re-parent only the PR's own commits onto the default branch, then
  supersede with a fresh PR:

  ```bash
  git rebase --onto "origin/$DEFAULT_BRANCH" "$LAST_BASE_COMMIT" HEAD
  git push --force-with-lease
  ```

  Open a NEW PR to `$DEFAULT_BRANCH`; cross-link both ways with a lifecycle
  comment noting it supersedes the closed one. Reuse prior adversarial-review
  clearance only after recording a fresh clearance for the rebased HEAD.

### Overwrite Mode (default)

```bash
gh pr checkout "$PR_NUMBER"
```

Verify branch is clean and up to date with its base:

```bash
git status --short
git log --oneline "$(git merge-base HEAD origin/$(gh pr view $PR_NUMBER --json baseRefName -q .baseRefName))..HEAD"
```

Branch has merge conflicts with base → run `wk-pr-update` before proceeding.

### Stack Mode

Compute new branch name from existing head + suffix:

```bash
HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName -q .headRefName)
NEW_BRANCH="${HEAD_BRANCH}-takeover"
git fetch origin "$HEAD_BRANCH"
git checkout -b "$NEW_BRANCH" "origin/$HEAD_BRANCH"
```

New PR targets `$HEAD_BRANCH` as base. Stacked-on-draft rule: `$HEAD_BRANCH` is
itself an unapproved draft PR → surface this choice before continuing:

> "The base branch `{HEAD_BRANCH}` is still a draft PR. Options:
> (A) Stack here anyway — reviewer must merge both in sequence.
> (B) Retarget to the repo default branch — combines both changesets.
> (C) Cancel."
>
> Auto-mode default: **B** (retarget to default branch).

---

## Step 4: Orient to the Existing Work

Read all files touched by existing commits:

```bash
git diff --name-only "$(git merge-base HEAD "origin/$(gh pr view $PR_NUMBER --json baseRefName -q .baseRefName)")"
```

Read each changed file. Understand:
- Pattern/convention being followed
- Incomplete sections (TODO, FIXME, `raise NotImplementedError`)
- Tests exist? pass?

Run the test suite → establish a baseline:

```bash
# Adjust for the project's test command
bundle exec rspec --format progress 2>&1 | tail -20   # Ruby
pytest -x -q 2>&1 | tail -20                          # Python
go test ./... 2>&1 | tail -20                         # Go
npm test -- --passWithNoTests 2>&1 | tail -20         # JS/TS
```

Record passing / failing / skipped. Failure from original author's work = a
**pre-existing failure** → document it, do not treat it as yours.

**Diff dominated by documentation / prose / config rather than code** → "does it
still pass" is the wrong baseline; often no runnable suite. Substitute a
**gate-preservation audit**:

- Run the repo's pre-commit/pre-push hooks as the executable baseline.
- Diff each touched file against base → enumerate rules, links, counts the change
  claims to preserve, verify each survived the compression (parallel subagents
  scale well across many files).
- Real takeover risk: a silently dropped load-bearing rule inside compressed
  prose, which no test catches.

---

## Step 5: Establish Co-Authorship

Identify the original author's Git identity:

```bash
# From the existing commits
git log --format="%an <%ae>" "$(git merge-base HEAD "origin/$(gh pr view $PR_NUMBER --json baseRefName -q .baseRefName)")..HEAD" | sort -u
```

Sole author across those commits is the user (taking over one's own PR) →
co-authorship machinery is a no-op; skip Step 5 and the `$WK_CO_AUTHOR` trailer
entirely.

Store as `$ORIGINAL_AUTHOR`. Every commit during takeover must carry:

```
Co-Authored-By: $ORIGINAL_AUTHOR
```

When invoking `wk-commit`, pass the co-author trailer explicitly:

```bash
# wk-commit will append co-author via its commit template
export WK_CO_AUTHOR="$ORIGINAL_AUTHOR"
```

---

## Step 6: Plan the Remaining Work

From Step 4's orientation, produce a task list:

1. Unresolved review feedback → items to implement
2. Incomplete code sections → items to finish
3. Missing tests → items to add
4. Pre-existing failures → flag as pre-existing; include remediation if in scope

Estimated work > 30% of original diff line-count AND in **overwrite mode** →
auto-switch to **stack mode**:

```bash
ORIGINAL_LINES=$(gh pr diff "$PR_NUMBER" | grep -c '^[+-]')
ESTIMATED_NEW_LINES=<your estimate>
if [ "$ESTIMATED_NEW_LINES" -gt $(( ORIGINAL_LINES * 30 / 100 )) ]; then
  echo "Scope exceeds 30% — switching to stack mode"
  # Re-run Step 3 in stack mode
fi
```

---

## Step 7: Run `wk-workflow`

Invoke the full `wk-workflow` as if this were new work:

```
Skill("wk-workflow")
```

Key phase adaptations:

| Phase | Adaptation |
|-------|-----------|
| **Plan** | Start from the existing work; fill gaps identified in Step 6 |
| **Implement** | Commit incrementally via `wk-commit` with `$WK_CO_AUTHOR` set |
| **Test** | Cover both original code and new additions; pre-existing failures must be flagged explicitly |
| **Adversarial Review** | Review considers the full diff (original + takeover), not just new changes |
| **PR** | See Step 8 for mode-specific PR handling |
| **Self-Review** | User posts self-review; user MUST NOT approve the PR |
| **Retro** | Capture learnings with `wk-learn pr-takeover` at session end |

---

## Step 8: Update or Create the PR

### Overwrite Mode

PR already exists. Update description to reflect combined work:

```bash
gh pr edit "$PR_NUMBER" --body "$(cat <<'EOF'
<combined description>

> **Note:** This PR has been taken over by @{user}. Original work by @{original_author}.
> Co-authored commits from this point forward carry `Co-Authored-By` trailers.

EOF
)"
```

Push when adversarial review clears:

```bash
git push origin HEAD
```

### Stack Mode

Create a new PR targeting the original head branch as base:

```bash
gh pr create \
  --title "[Takeover] <original title> — continued" \
  --base "$HEAD_BRANCH" \
  --draft \
  --body "$(cat <<'EOF'
Stacked on #<PR_NUMBER> (@{original_author}'s PR).

## What this PR adds
<summary of takeover work>

## Relationship to base PR
This PR continues work from #<PR_NUMBER>. It should be merged after the base PR
is merged. Both authors own the combined changeset.

EOF
)"
```

Update the original PR description to note the stacked continuation:

```bash
gh pr edit "$PR_NUMBER" --body "$(existing_body)

---
> **Continued in:** #<new_pr_number> (stacked, @{user})"
```

---

## Step 9: Self-Review

Invoke `wk-self-review` → post inline comments documenting decisions and
non-obvious choices added during takeover:

```
Skill("wk-self-review")
```

**Hard rule:** Do not submit an approving review. Post comments only.

---

## Step 10: Handoff Summary

Post a comment on the PR summarizing the takeover:

```bash
gh pr comment "$PR_NUMBER" --body "$(cat <<'EOF'
**Takeover summary** (@{user} → continuing from @{original_author})

- Mode: overwrite | stack (circle one)
- Pre-existing failures at checkout: <list or "none">
- Work completed in this session: <bullet list>
- Unresolved items deferred: <bullet list or "none">
- Stacked PR (if created): #<number> or N/A

All new commits carry `Co-Authored-By: @{original_author}`.
EOF
)"
```

Build the `Co-Authored-By:` email per wk-commit's HARD RULE: the current user's
address is `$WK_SKILLS_EMPLOYEE_EMAIL` (unset → STOP); `@{original_author}` uses
their `<id>+<login>@users.noreply.github.com` form. Never guess `<login>@<domain>`.

---

## Common Mistakes

- **Assuming the branch is mergeable** — always run tests at Step 4 before adding
  code. Document pre-existing failures separately.
- **Stacking on a draft base** — follow the three-option check in Step 3 Stack
  Mode. Auto-mode retargets to the default branch.
- **Approving your own work** — you are now a co-author; the approval constraint
  applies even though you didn't write the original code.
- **Losing co-author trailers** — set `$WK_CO_AUTHOR` before any `wk-commit`
  invocation. Commits without the trailer lose attribution history.
- **Expanding scope silently** — 30% threshold triggers mid-session → switch
  modes and surface the decision to the user before proceeding.

---

## Quick Reference

| Command | Behavior |
|---------|----------|
| `/wk-pr-takeover 123` | Overwrite mode — check out PR #NNN, continue on existing branch |
| `/wk-pr-takeover 123 --stack` | Stack mode — create new branch on top of PR #NNN |
| `/wk-pr-takeover <url>` | Accept full PR URL, extract number automatically |

---

## Requirements

- `gh` CLI authenticated
- `$GITHUB_ORG` set (or `wk-gh` will prompt)
- `$WK_SKILLS_HOME` set
- Write access to the repository (push to the existing branch in overwrite mode)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument:

```
Skill("wk-learn", "pr-takeover")
```
