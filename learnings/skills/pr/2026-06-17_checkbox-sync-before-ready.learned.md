---
skill: wk-pr
date: 2026-06-17
type: correction
severity: medium
---

Check off test-plan checkboxes in the PR description before marking ready, not after.

**What happened:** After CI turned green, the agent moved directly to `gh pr ready` without updating the PR description checkboxes. The user caught the unchecked boxes and asked for a fix.

**Root cause:** Step 4 (CI green) instructs syncing the PR description and checking off test-plan items, but this was skipped in the rush to `gh pr ready`.

**Suggested fix:** Make the checkbox-sync a blocking gate in the CI-green step: before calling `gh pr ready`, re-read the PR body and check off every test-plan item that is now satisfied by green CI and passing local checks.
