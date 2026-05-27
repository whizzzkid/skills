---
name: wk-worktree-cleanup
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
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.27-225202'
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

Resolve the default branch dynamically and store as `{default-branch}`:

```bash
$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

If both fail, fall back to whichever of `main` or `master` exists locally.
Use `{default-branch}` in all subsequent git commands.

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

## Step 4: Capture learnings before deletion

**HARD RULE:** A worktree often holds the only copy of session-specific context —
ad-hoc notes, agent transcripts, draft plans not yet distilled into
`$WK_SKILLS_HOME/learnings/`. Once the worktree is removed, that
context is unrecoverable. Run `wk-retro` against each merged
worktree **before** calling `git wtr`.

`wk-retro` writes to global memory (`~/.claude/memory/`). `wk-learn` is for skill-specific learnings (`$WK_SKILLS_HOME/learnings/skills/`) — do not substitute one for the other here.

### Disposable paths — skip retro and clean without prompting

Some untracked content is always disposable: **temporary directories created
by the agent during this session** (review playgrounds, build artifacts, IDE
caches), OS metadata files, and editor swap files matched by `.gitignore`.

If the only untracked content falls into these categories, treat the worktree
as clean and proceed. Before `git wtr` (Step 5), `git clean -fd` may run
without per-worktree user confirmation to remove them.

Anything else — session notes, draft plans, uncommitted code — still triggers
the normal retro check.

For each branch classified as `merged`:

- **Pre-delete content scan.** Surface uncommitted or stashed content before any retro/delete decision — merged status only proves committed work landed; staged, untracked-non-disposable, or stashed content can still be unique to this worktree:

  ```bash
  git -C worktrees/{branch} status --short
  git -C worktrees/{branch} stash list
  ```

  If either reports non-empty content (beyond the disposable-paths classifier set), surface to the user before proceeding.

- **Author check — skip retro when branch is owned by another user.** `wk-retro` reflects the current session; running it against another contributor's branch yields empty lenses:

  ```bash
  AUTHOR=$(git -C worktrees/{branch} log -1 --format='%ae')
  ME=$(git config user.email)
  [ "$AUTHOR" = "$ME" ] || SKIP_RETRO=1
  ```

  If `SKIP_RETRO=1`, jump to Step 5 directly; record the skip reason in the cleanup report.

- **Retro already run?** (learning file mtime within this worktree's active window, entry in `~/.claude/memory/retro-log.md` for this branch/PR, or explicit user skip recorded this run) → skip retro, proceed to Step 5.
- **No signal found and author matches** → invoke `wk-retro` before deletion: `Skill(wk-retro, args="--worktree worktrees/{branch}")`. If `wk-retro` is unavailable or fails, stop and ask the user before proceeding.
- **After retro returns** → confirm the worktree is clean, then proceed to Step 5.

## Step 5: Clean Up Merged Worktrees

For each **merged** branch whose retro has been confirmed (Step 4),
remove the worktree and delete the branch.

### Pre-clean disposable untracked content

Run `git clean -fd` inside the worktree before `git wtr`. `git worktree
remove` refuses to delete a worktree that contains untracked files and
errors out without `--force`. Falling back to `--force` masks unrelated
uncommitted work the disposable-paths classifier missed.

- Scope the clean to the worktree path; do not run it in the primary
  checkout.
- Only run after Step 4 confirmed every untracked path is disposable —
  the classifier is the gate, `git clean` is the executor.
- If a non-disposable untracked path appears between Step 4 and Step 5
  (e.g., a generated file from `wk-retro`), re-run Step 4's check.

```bash
git -C worktrees/{branch} clean -fd
git wtr {branch}
```

The `git wtr` alias expands to `git worktree remove worktrees/{branch} && git branch -D {branch}`.

**HARD RULE:** Never call `git wtr` on a branch that has not been confirmed
merged. The `-D` flag force-deletes the branch regardless of merge status.
If in doubt, classify as unmerged and let the user decide.

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

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn worktree-cleanup`).
