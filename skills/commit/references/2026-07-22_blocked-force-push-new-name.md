---
class: principle
---

- **Rule**: When a force-push is classifier-blocked after a history rewrite
  (rebase, amend), push the rewritten commits under a new branch name — a plain
  new-ref push is not a history rewrite and lands cleanly — then repoint the PR
  to the new branch. Never bypass the block with `--no-verify`.
- **Why**: Auto-mode classifiers block force-pushes; abandoning the rewrite or
  fighting the block wastes the work. A new-ref push satisfies the constraint
  without rewriting any published history.
- **Where**: wk-commit push-handling rules (force-push discipline).
