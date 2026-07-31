---
class: principle
---

# Retarget dependents before stale-head deletion

**Rule:** When a merge workflow starts after the pull request is already merged,
audit the remote head and retarget open child pull requests before deletion.
Retain and report the branch when a child cannot be retargeted.

**Why:** The skipped merge command never ran its child-retarget or
`--delete-branch` path, so cleanup cannot assume either side effect occurred.

**Where:** `wk-pr-merge` Step 10.
