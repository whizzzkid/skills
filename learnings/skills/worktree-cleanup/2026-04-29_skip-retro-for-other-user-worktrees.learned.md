---
skill: wk-worktree-cleanup
date: 2026-04-29
type: gap
severity: low
---

Skip retro for worktrees owned by other users — there is no session context to capture.

**What happened:** Skill required wk-retro before every merged-worktree deletion. Running retro against branches owned by other users (different git user login) always yields empty lenses and wastes time.

**Root cause:** Skill applies the "retro before every deletion" rule uniformly without distinguishing branch ownership.

**Suggested fix:** Before invoking wk-retro, check whether the worktree's branch was authored by the current git user (`git log --format='%ae' -1 <sha>`). If the author email differs, skip the retro step — no session context is available.
