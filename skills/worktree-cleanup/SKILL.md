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
  - "Bash(git log:*)"
  - "Bash(stat:*)"
  - Skill
  - AskUserQuestion
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.01-080026'
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

## Step 4: Capture learnings before deletion (HARD RULE)

A worktree often holds the only copy of session-specific context —
ad-hoc notes, agent transcripts, draft plans not yet distilled into
`$WK_SKILLS_HOME/learnings/`. Once the worktree is removed, that
context is unrecoverable. Run `wk:retro` against each merged
worktree **before** calling `git wtr`.

### Disposable paths — skip retro and clean without prompting

Some untracked content in a worktree is **always disposable** and
should not block cleanup or trigger the retro check:

| Path | Why disposable |
|------|----------------|
| `.review-playground/` | `wk:pr-review`'s scratch space for reproduction scripts and analysis docs. Findings are already posted to the PR before merge; the directory has no lasting value. |
| `.DS_Store`, `Thumbs.db` | OS noise. |
| `*.swp`, `*.swo`, `.idea/`, `.vscode/` (when not committed) | Editor noise. |
| `node_modules/`, `.venv/`, `target/`, `dist/`, `build/`, `.next/`, `.cache/` (when matched by `.gitignore`) | Build artifacts; trivially regenerable. |

When checking the worktree for retro signals, **ignore these paths
entirely** — their presence is not a "fresh context" signal, and
they should not appear in the worktree's "dirty" list. If the only
untracked content is in these paths, treat the worktree as clean
and proceed; before `git wtr` (Step 5), `git clean -fd` may run
without per-worktree user confirmation to remove them.

Anything outside this list still triggers the normal retro check.

For each branch classified as `merged`:

1. Detect whether retro has already been run for this worktree.
   Look for any of these signals (any one is sufficient):
   - A learning file in `$WK_SKILLS_HOME/learnings/skills/**/` whose
     mtime falls inside the worktree's active window
     (worktree creation → most-recent commit time).
   - An entry in `~/.claude/memory/retro-log.md` referencing the
     branch name or its PR number.
   - A user override: "skip retro for this worktree" recorded in
     this run.
2. If no signal is present, **invoke `wk:retro` against the
   worktree** before cleanup:

   ```
   Skill(wk:retro, args="--worktree worktrees/{branch}")
   ```

   `wk:retro`'s 5-lens reflection runs against the worktree's
   conversation/transcript and writes any captured learnings to
   `$WK_SKILLS_HOME/learnings/skills/<skill>/` and the global
   retro log.
3. After the retro returns, confirm the working tree of the
   worktree is clean (no fresh learning files left uncommitted).

In auto mode, retro runs without prompting — the cost of an empty
retro is small; the cost of a missed learning is unrecoverable.

If `wk:retro` is unavailable or fails, **stop and ask** before
deleting the worktree. Do not silently proceed; the user may want
to capture context manually.

## Step 5: Clean Up Merged Worktrees

For each **merged** branch whose retro has been confirmed (Step 4),
remove the worktree and delete the branch:

```bash
git wtr {branch}
```

This alias expands to `git worktree remove worktrees/{branch} && git branch -D {branch}`.

**HARD RULE: Never call `git wtr` on a branch that has not been confirmed
merged.** The `-D` flag force-deletes the branch regardless of merge status.
If in doubt, classify as unmerged and let the user decide.

**HARD RULE: Never call `git wtr` until Step 4 has either run
`wk:retro` against the worktree or recorded an explicit skip.**
Worktree-local learnings are unrecoverable post-deletion.

## Step 6: Prune Stale References

After removing merged worktrees, clean up any stale metadata:

```bash
git worktree prune
```

## Step 7: Report

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

## Post-Completion

Invoke `wk:learn` with this skill's short name as the argument (e.g., `wk:learn worktree-cleanup`).
