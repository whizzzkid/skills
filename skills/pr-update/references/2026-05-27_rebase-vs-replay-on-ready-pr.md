---
class: principle
---

- **Rule**: When `$AHEAD ≥ 5` and the PR is ready-for-review (`isDraft = false`), override the patch-replay heuristic and use merge to preserve atomic commit history under active review.
- **Why**: Patch-replay squashes N commits into 1; squashing mid-review reshapes the diff under readers without adding clarity. A ready PR is an explicit signal that the commit history is intended to be readable.
- **Where**: wk-pr-update Stage 2 integration-strategy table (new row + `gh pr view --json isDraft` check before patch-replay).
