---
class: principle
---

- **Rule**: When a rebase/history-rewrite requires a force-push, expect the
  auto-mode classifier to block it (same class as `--amend`). Surface the exact
  `git push --force-with-lease` (not `--force`) for one-time approval in the same
  response, rather than issuing it and treating the denial as a hard stop.
- **Why**: Auto mode treats any force-push as history-rewriting and requires
  explicit confirmation, even when the rebase that produced it was authorized.
  `--force-with-lease` is the safe default (refuses if the remote advanced).
- **Where**: wk-commit force-push discipline. Paired with the new-branch-name
  fallback for a declined approval.
