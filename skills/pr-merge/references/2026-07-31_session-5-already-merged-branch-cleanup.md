---
class: principle
---

# Audit remote cleanup after an external merge

**Rule:** When a merge workflow starts after the pull request is already merged, verify the remote head before local
cleanup. Retain it for open child pull requests; otherwise apply the normal branch-deletion preference and verify.

**Why:** The current run skipped the merge command, so it cannot assume `--delete-branch` executed.

**Where:** `wk-pr-merge` Step 10.
