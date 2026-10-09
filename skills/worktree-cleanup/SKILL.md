---
name: wk-worktree-cleanup
description: >-
  Clean up git worktrees whose branches have been merged. Use when asked to
  clean up worktrees, remove merged worktrees, tidy up branches, or prune
  stale worktrees. Lists all worktrees, checks merge status, removes merged
  ones, and reports unmerged ones for the user to decide.
argument-hint: '[--current]'
allowed-tools:
  - "Bash(git wtl:*)"
  - "Bash(git wtr:*)"
  - "Bash(git symbolic-ref:*)"
  - "Bash(git branch:*)"
  - "Bash(git worktree:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(gh pr list:*)"
  - "Bash(git log:*)"
  - "Bash(git clean:*)"
  - "Bash(git stash list:*)"
  - "Bash(git status:*)"
  - "Bash(stat:*)"
  - "Bash(cd:*)"
  - "Bash(dirname:*)"
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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Worktree Cleanup

Scan worktrees → clean merged ones → report unmerged ones for the user to decide. "list worktrees": run `git wtl`
(Step 1) and show the output. "remove worktree X": remove only that one, after confirming merge status (Step 3).
Requires: `git wtl`/`git wtr` aliases in `$HOME/.gitconfig`; `gh` authenticated with repo access; run from the main
worktree (repo root). `--current` (clean the worktree you are inside, e.g., after
[`wk-pr-merge`](../pr-merge/README.md)): follow [references/current-mode.md](references/current-mode.md) and stop.

## Step 1: List Worktrees

```bash
git wtl
```

Parse each line (`/path/to/repo/worktrees/feat-x  def5678 [feat-x]`) into path + bracketed branch. Skip the main
worktree (first entry without `/worktrees/`; never remove) and any `(detached HEAD)` entry.

## Step 2: Detect the Default Branch

Store as `{default-branch}` and use it in every later command; both fail → whichever of `main`/`master` exists locally:

```bash
$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

## Step 3: Check Merge Status

Run both; **merged** if either passes, **unmerged** if neither, **unknown** if `gh` failed (no remote/auth; treat as
unmerged). Local, then remote (`> 0` means a merged PR exists):

```bash
git branch --merged {default-branch} | grep -qw '{branch}'
```

```bash
gh pr list --state merged --head '{branch}' --json number,title --jq 'length'
```

## Step 4: Capture learnings before deletion

**HARD RULE:** A worktree often holds the only copy of session-specific context (notes, transcripts, draft plans not
yet distilled into `$WK_SKILLS_HOME/learnings/`); removal is unrecoverable. Run `wk-retro` against each merged worktree
**before** `git wtr`. `wk-retro` → `$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md` (only distilled rules to
`$HOME/.claude/memory/`); `wk-learn` → `$WK_SKILLS_HOME/learnings/skills/`; never substitute one for the other.

Disposable paths (skip retro, clean without prompting): `.agents/`, `skills-lock.json`, `.review-playground/` (even
when not gitignored), plus `.gitignore`-matched build artifacts, IDE caches, OS metadata, editor swap files. Only
disposable untracked content → worktree is clean; `git clean -fd` may run before `git wtr` without per-worktree
confirmation. Anything else (notes, plans, uncommitted code) → normal retro check.

For each `merged` branch, in order:

1. **Content scan** — merged proves only committed work landed. Any non-disposable output → surface to the user
   before any retro/delete decision:

   ```bash
   git -C worktrees/{branch} status --short
   git -C worktrees/{branch} stash list
   ```

2. **Author check** — another user's branch yields empty retro lenses; `SKIP_RETRO=1` → go to Step 5 and record the
   skip reason in the report:

   ```bash
   AUTHOR=$(git -C worktrees/{branch} log -1 --format='%ae')
   ME=$(git config user.email)
   [ "$AUTHOR" = "$ME" ] || SKIP_RETRO=1
   ```

3. **Retro already run** (learning-file mtime in this worktree's active window, `$HOME/.claude/memory/retro-log.md`
   entry for this branch/PR, or explicit user skip this run) → Step 5.
4. Otherwise invoke `Skill(wk-retro, args="--worktree worktrees/{branch}")`; unavailable or failed → stop and ask.
   After it returns, confirm the worktree is clean, then Step 5.

## Step 5: Clean Up Merged Worktrees

For each merged branch with retro confirmed, pre-clean then remove (`git wtr` = `git worktree remove
worktrees/{branch} && git branch -D {branch}`). `git worktree remove` refuses untracked files; never fall back to
`--force` (masks uncommitted work the classifier missed). Scope `git clean` to the worktree path, never the primary
checkout, and run it only after Step 4 confirmed every untracked path disposable; a new non-disposable path since
Step 4 (e.g., a `wk-retro` file) → re-run Step 4's check.

```bash
git -C worktrees/{branch} clean -fd
git wtr {branch}
```

**HARD RULE:** Never call `git wtr` on a branch not confirmed merged. The `-D` flag force-deletes the branch regardless
of merge status. If in doubt, classify as unmerged and let the user decide.

Then prune stale metadata:
```bash
git worktree prune
```

## Step 6: Report

- **Cleaned up** — table `Branch | Merged via` (`Local (git branch --merged)` or `GitHub PR #NNN`); none → "No
  merged worktrees found — nothing to clean up."
- **Still active (unmerged)** — table `Branch | Path | PR Status` (`Open PR #NNN` / `No PR found`); none → "All
  worktrees have been cleaned up." Otherwise tell the user: "These worktrees have unmerged branches. Let me know if
  you'd like to force-remove any of them, or I can leave them as-is."

## Post-Completion

Invoke `wk-learn worktree-cleanup`.
