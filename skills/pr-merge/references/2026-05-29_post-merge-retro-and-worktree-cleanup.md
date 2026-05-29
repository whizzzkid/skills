---
class: principle
skill: wk-pr-merge
date: 2026-05-29
---

# Post-merge: retro then worktree cleanup

- **Rule:** After a successful merge, invoke `wk-retro` (Step 9) to distill the
  session, then `wk-worktree-cleanup --current` (Step 10) to remove the merged
  branch's worktree.
- **Why:** Merging ends the session — ad-hoc decisions/review trade-offs are
  lost if not distilled before the worktree (their only copy) is removed.
- **Where:** Step 9 (Capture session learnings) and Step 10 (Clean up the
  current worktree).
- **Note:** Step 9's retro satisfies `wk-worktree-cleanup`'s pre-delete retro
  guard, so retro does not run twice.
