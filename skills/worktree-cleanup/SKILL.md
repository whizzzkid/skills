---
name: wk:worktree-cleanup
description: >-
  Clean up git worktrees whose branches have been merged. Use when asked to
  clean up worktrees, remove merged worktrees, tidy up branches, or prune
  stale worktrees. Lists all worktrees, checks merge status, removes merged
  ones, and reports unmerged ones for the user to decide.
allowed-tools:
  - "Bash(git wtl:*)"
  - "Bash(git wtr:*)"
  - "Bash(git symbolic-ref:*)"
  - "Bash(git branch:*)"
  - "Bash(git worktree:*)"
  - "Bash(gh pr list:*)"
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.04.22-070656'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Worktree Cleanup

Scans all git worktrees in the current repo, identifies which branches have
been merged, cleans up the merged ones, and reports any unmerged worktrees
so the user can decide what to do with them.

## Prerequisites

- Git aliases configured: `git wtl`, `git wtr`
- `gh` CLI authenticated (for checking PR merge status on GitHub)
- Must be run from the main worktree (repo root), not from inside a worktree

## Step 1: List Worktrees

```bash
git wtl
```

This outputs lines like:

```
/path/to/repo                   abc1234 [main]
/path/to/repo/worktrees/feat-x  def5678 [feat-x]
/path/to/repo/worktrees/fix-y   ghi9012 [fix-y]
```

Parse each line to extract the **path** and **branch name** (in brackets).

**Skip the main worktree** — the first entry that does not have `/worktrees/`
in its path. This is the repo root and must never be removed.

Also skip any worktree with a detached HEAD (shown as `(detached HEAD)` instead
of a branch name in brackets).

## Step 2: Detect the Default Branch

Determine whether the repo uses `main` or `master`:

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```

If that fails, fall back to checking which of `main` or `master` exists locally.
Use this as `{default-branch}` in subsequent steps.

## Step 3: Check Merge Status

For each worktree branch, check if it has been merged using **both** methods.
A branch is considered merged if **either** check passes.

### Local check

```bash
git branch --merged {default-branch} | grep -qw '{branch}'
```

### Remote check (GitHub PR status)

```bash
gh pr list --state merged --head '{branch}' --json number,title --jq 'length'
```

If the result is `> 0`, the branch has a merged PR.

### Classify each branch

- **merged** — either check confirmed it
- **unmerged** — neither check confirmed it
- **unknown** — `gh` command failed (e.g., no remote, no auth); treat as unmerged

## Step 4: Clean Up Merged Worktrees

For each **merged** branch, remove the worktree and delete the branch:

```bash
git wtr {branch}
```

This alias expands to `git worktree remove worktrees/{branch} && git branch -D {branch}`.

**HARD RULE: Never call `git wtr` on a branch that has not been confirmed
merged.** The `-D` flag force-deletes the branch regardless of merge status.
If in doubt, classify as unmerged and let the user decide.

## Step 5: Prune Stale References

After removing merged worktrees, clean up any stale metadata:

```bash
git worktree prune
```

## Step 6: Report

Present a summary with two sections:

### Cleaned up

```
| Branch | Merged via |
|--------|-----------|
| feat-x | Local (git branch --merged) |
| fix-y  | GitHub PR #NNN |
```

If nothing was cleaned, say: "No merged worktrees found — nothing to clean up."

### Still active (unmerged)

```
| Branch | Path | PR Status |
|--------|------|-----------|
| wip-z  | worktrees/wip-z | Open PR #NNN |
| spike-a | worktrees/spike-a | No PR found |
```

If there are no unmerged worktrees, say: "All worktrees have been cleaned up."

For unmerged worktrees, let the user know:
> "These worktrees have unmerged branches. Let me know if you'd like to
> force-remove any of them, or I can leave them as-is."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "clean up worktrees" | Full scan, remove merged, report unmerged |
| "list worktrees" | Just run `git wtl` and show the output |
| "remove worktree X" | Remove a specific worktree (confirm merge status first) |

## Requirements

- Git worktree aliases (`git wtl`, `git wtr`) in `~/.gitconfig`
- `gh` CLI authenticated with repo access (for PR merge checks)
- Shell access

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/worktree-cleanup"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/worktree-cleanup/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:worktree-cleanup
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `worktree-cleanup/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
