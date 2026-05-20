---
name: pr-body-rename-sync
description: Renames in code must propagate to the PR body before push.
class: principle
---

- **Rule:** Enumerate every symbol deleted in
  `git diff "$BASE...HEAD" --diff-filter=D` and grep the PR body
  for each. Any hit is a blocker until the body is updated.
- **Why:** Rename commits update code in-tree but leave the PR body
  stale — body edits live outside the file diff, so the rename
  never reaches the test plan, file table, or summary text.
- **Where:** Sweep 2.10 (PR metadata sync), final bullet.
