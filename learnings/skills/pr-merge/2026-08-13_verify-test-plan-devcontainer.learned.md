---
skill: wk-pr-merge
date: 2026-08-13
type: correction
severity: medium
verified-against-source: n/a
---

Verify UI test-plan items in the devcontainer instead of treating them as paperwork blockers

**What happened:** A PR with unchecked test-plan items for a UI CSS fix was presented to the user as a merge gate requiring manual waiver. The agent did not offer to spin up the devcontainer and verify the items itself, despite the project requiring all local work inside the devcontainer.

**Root cause:** The merge skill's Step 5 treats unchecked `- [ ]` items as blockers to surface, but has no instruction to attempt verification of verifiable items (especially UI changes) before blocking. The agent defaulted to asking the user instead of doing the work.

**Suggested fix:** Add a sub-step to Step 5: when unchecked test-plan items describe verifiable UI behavior and a devcontainer is available, offer to spin up the devcontainer and verify them before presenting them as blockers. Only block on items the agent genuinely cannot verify (e.g. requires production access, external system state).
