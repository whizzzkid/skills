---
class: principle
skill: wk-pr
date: 2026-06-23
---

**Rule**

Before `gh pr ready`, verify the CI run for the *current* HEAD SHA has completed
and is green. A green result against an earlier HEAD does not satisfy the gate;
each push that lands new commits starts a fresh CI run that must finish first.
Never race `gh pr ready` ahead of a still-`running` build.

**Why**

Marking ready while the fresh CI run is still `running` races verification — the
prior run only covered the older commits. "Each commit = each CI run must
complete."

**Where**

Step 5 (Mark Ready), as a HARD RULE immediately before `gh pr ready`, paired with
the existing test-plan-checkbox gate and the Quick Reference "new commits → re-poll" row.
