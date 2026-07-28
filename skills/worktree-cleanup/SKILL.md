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
  version: "2026.07.28-171130"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Worktree Cleanup

Scan all git worktrees in the current repo → identify merged branches → clean
merged ones → report unmerged ones for the user to decide.

## Prerequisites

- Git aliases configured: `git wtl`, `git wtr`
- `gh` CLI authenticated (for PR merge status on GitHub)
- Default mode runs from the main worktree (repo root). To clean the worktree
  you are currently inside, use `--current` mode (below) — it handles the
  chdir-to-main step `git worktree remove` requires.

## Mode: clean the current worktree (`--current`)

- Removes the worktree the agent is **currently inside** — e.g., after
  [`wk-pr-merge`](../pr-merge/README.md) merges this branch's PR.
- `git worktree remove` cannot remove the current working directory → this mode
  chdir's to the main worktree first.

```bash
CURRENT_WT=$(git rev-parse --show-toplevel)
MAIN_WT=$(dirname "$(git rev-parse --git-common-dir)")
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
```

- `CURRENT_WT` == `MAIN_WT` → not inside a linked worktree; report and stop.
  Never remove the repo root.
- Verify `CURRENT_BRANCH` is merged via Step 3. If `unmerged`/`unknown`, stop
  and ask the user — do not auto-remove unmerged work.
- Run Step 4's retro + content-scan guard against `CURRENT_WT`. Skip retro if
  it already ran this session (e.g., `wk-pr-merge` Step 9 invoked it).
- After the guard confirms clean, chdir to main and remove:

  ```bash
  cd "$MAIN_WT"
  git -C "$CURRENT_WT" clean -fd      # only after disposable-paths gate
  git worktree remove "$CURRENT_WT"
  git branch -D "$CURRENT_BRANCH"
  git worktree prune
  ```

- Report removed worktree/branch + new working directory (`MAIN_WT`). Then stop
  — do not fall through to the full sibling scan.

## Step 1: List Worktrees

```bash
git wtl
```

Outputs lines like:

```
/path/to/repo                   abc1234 [main]
/path/to/repo/worktrees/feat-x  def5678 [feat-x]
/path/to/repo/worktrees/fix-y   ghi9012 [fix-y]
```

- Parse each line → extract **path** and **branch name** (in brackets).
- **Skip the main worktree** — first entry without `/worktrees/` in its path.
  Repo root; never remove.
- Skip any detached-HEAD worktree (shown as `(detached HEAD)` instead of a
  bracketed branch name).

## Step 2: Detect the Default Branch

Resolve dynamically, store as `{default-branch}`:

```bash
$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

- If both fail → fall back to whichever of `main`/`master` exists locally.
- Use `{default-branch}` in all subsequent git commands.

## Step 3: Check Merge Status

Check each branch with **both** methods; merged if **either** passes.

- Local check:

  ```bash
  git branch --merged {default-branch} | grep -qw '{branch}'
  ```

- Remote check (GitHub PR status) — result `> 0` means a merged PR exists:

  ```bash
  gh pr list --state merged --head '{branch}' --json number,title --jq 'length'
  ```

Classify each branch:

- **merged** — either check confirmed it
- **unmerged** — neither check confirmed it
- **unknown** — `gh` failed (no remote, no auth); treat as unmerged

## Step 4: Capture learnings before deletion

**HARD RULE:** A worktree often holds the only copy of session-specific context
— ad-hoc notes, agent transcripts, draft plans not yet distilled into
`$WK_SKILLS_HOME/learnings/`. Once removed, that context is unrecoverable. Run
`wk-retro` against each merged worktree **before** calling `git wtr`.

- `wk-retro` → session narrative to
  `$WK_SKILLS_HOME/learnings/retrospect/<YYYY-MM-DD>.md` (and only distilled
  rules, if any, to `$HOME/.claude/memory/`).
- `wk-learn` → skill-specific learnings under
  `$WK_SKILLS_HOME/learnings/skills/`. Do not substitute one for the other here.

### Disposable paths — skip retro and clean without prompting

- Always disposable: agent-infrastructure artifacts the skills tooling
  regenerates each run — `.agents/`, `skills-lock.json`, `.review-playground/`
  (carry no unique session context; disposable even when not gitignored) — plus
  build artifacts, IDE caches, OS metadata files, and editor swap files matched
  by `.gitignore`.
- If the only untracked content is disposable → treat worktree as clean and
  proceed. Before `git wtr` (Step 5), `git clean -fd` may run without
  per-worktree user confirmation to remove them.
- Anything else (session notes, draft plans, uncommitted code) → triggers the
  normal retro check.

For each `merged` branch:

- **Pre-delete content scan.** Merged status only proves committed work landed;
  staged, untracked-non-disposable, or stashed content can still be unique to
  this worktree. Surface it before any retro/delete decision:

  ```bash
  git -C worktrees/{branch} status --short
  git -C worktrees/{branch} stash list
  ```

  Either reports non-empty content (beyond the disposable-paths classifier set)
  → surface to the user before proceeding.

- **Author check — skip retro when another user owns the branch.** `wk-retro`
  reflects the current session; running it on another contributor's branch
  yields empty lenses:

  ```bash
  AUTHOR=$(git -C worktrees/{branch} log -1 --format='%ae')
  ME=$(git config user.email)
  [ "$AUTHOR" = "$ME" ] || SKIP_RETRO=1
  ```

  `SKIP_RETRO=1` → jump to Step 5 directly; record the skip reason in the
  cleanup report.

- **Retro already run?** (learning file mtime within this worktree's active
  window, entry in `$HOME/.claude/memory/retro-log.md` for this branch/PR, or
  explicit user skip recorded this run) → skip retro, proceed to Step 5.
- **No signal found and author matches** → invoke `wk-retro` before deletion:
  `Skill(wk-retro, args="--worktree worktrees/{branch}")`. If `wk-retro` is
  unavailable or fails, stop and ask the user before proceeding.
- **After retro returns** → confirm the worktree is clean, proceed to Step 5.

## Step 5: Clean Up Merged Worktrees

For each **merged** branch whose retro is confirmed (Step 4), remove the
worktree and delete the branch.

### Pre-clean disposable untracked content

- Run `git clean -fd` inside the worktree before `git wtr`. `git worktree
  remove` refuses to delete a worktree containing untracked files and errors out
  without `--force`. Falling back to `--force` masks unrelated uncommitted work
  the disposable-paths classifier missed.
- Scope the clean to the worktree path; never run it in the primary checkout.
- Only run after Step 4 confirmed every untracked path is disposable — the
  classifier is the gate, `git clean` is the executor.
- Non-disposable untracked path appears between Step 4 and Step 5 (e.g., a
  generated file from `wk-retro`) → re-run Step 4's check.

```bash
git -C worktrees/{branch} clean -fd
git wtr {branch}
```

`git wtr` expands to `git worktree remove worktrees/{branch} && git branch -D {branch}`.

**HARD RULE:** Never call `git wtr` on a branch not confirmed merged. The `-D`
flag force-deletes the branch regardless of merge status. If in doubt, classify
as unmerged and let the user decide.

## Step 6: Prune Stale References

Clean up stale metadata after removing merged worktrees:

```bash
git worktree prune
```

## Step 7: Report

Present two sections.

### Cleaned up

```
| Branch | Merged via |
|--------|-----------|
| feat-x | Local (git branch --merged) |
| fix-y  | GitHub PR #NNN |
```

Nothing cleaned → say: "No merged worktrees found — nothing to clean up."

### Still active (unmerged)

```
| Branch | Path | PR Status |
|--------|------|-----------|
| wip-z  | worktrees/wip-z | Open PR #NNN |
| spike-a | worktrees/spike-a | No PR found |
```

No unmerged worktrees → say: "All worktrees have been cleaned up."

For unmerged worktrees, tell the user:
> "These worktrees have unmerged branches. Let me know if you'd like to
> force-remove any of them, or I can leave them as-is."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "clean up worktrees" | Full scan, remove merged, report unmerged |
| "list worktrees" | Just run `git wtl` and show the output |
| "remove worktree X" | Remove a specific worktree (confirm merge status first) |
| `--current` | Clean the worktree you're inside (chdir to main, then remove) |

## Requirements

- Git worktree aliases (`git wtl`, `git wtr`) in `$HOME/.gitconfig`
- `gh` CLI authenticated with repo access (for PR merge checks)
- Shell access

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn worktree-cleanup`).
