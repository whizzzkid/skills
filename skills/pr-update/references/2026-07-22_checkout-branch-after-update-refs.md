---
class: principle
---

- **Rule**: Immediately after any `--update-refs` (or stack-rewriting) rebase,
  run `git branch --show-current` / `git status` and explicitly `git checkout`
  the intended branch before the next Write or commit. Never assume the rebase
  left HEAD on the branch you mean to work on next.
- **Why**: `--update-refs` moves branch *pointers* but leaves HEAD on whatever
  branch was checked out for the rebase — not the topmost branch — so the next
  commit silently lands on the wrong (parent) branch of the stack.
- **Where**: wk-pr-update Stage 3a (post-rebase, before resuming work).
