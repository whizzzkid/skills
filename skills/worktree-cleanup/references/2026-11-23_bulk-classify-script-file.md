---
class: principle
source: learnings/skills/worktree-cleanup/2026-11-23_bulk-classify-script-file.learned.md
date: 2026-11-23
skill: wk-worktree-cleanup
---

**Rule** — Run the Step 4 bulk classification pass from a scratch script executed with `bash`, emitting one
`branch|merged|dirty|author` row per worktree; never compose it as an inline loop in the interactive shell. Check
`git stash list` once per repo — `refs/stash` is shared by every worktree, so a per-worktree stash count is meaningless.

**Why** — An inline loop over ~60 worktrees in zsh failed on every body command ("command not found" from whole lines
treated as one word, plus a `?` glob error), producing garbage; the same logic from a bash script file worked. Root
cause inferred as zsh word-splitting/globbing differences, unverified beyond the symptom. The stash claim is verified:
`git rev-parse --git-path refs/stash` resolves into the common dir, and git shares all refs across worktrees except
`HEAD` and the per-worktree namespaces.

**Where** — `SKILL.md` → Step 4, "Bulk runs" sub-bullet and content-scan note. Also matches retrospect lesson
`2026-11-23_session-1` (worktree-cleanup).
