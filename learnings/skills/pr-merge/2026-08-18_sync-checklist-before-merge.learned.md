---
skill: wk-pr-merge
date: 2026-08-18
type: correction
severity: medium
verified-against-source: n/a
---

Sync PR test-plan checkboxes with verified results before proposing merge

**What happened:** After verifying all test-plan items via Playwright (sidebar scroll preservation, `aria-current` sync, client-side navigation), the agent proceeded toward merge without updating the PR description's checklist. The user had to explicitly remind the agent to check off verified items before merging.

**Root cause:** Step 5 scans for unchecked `- [ ]` items but does not instruct the agent to proactively check off items that were verified during the session. The agent treated verification and description-sync as independent steps rather than a pipeline where verification feeds checkbox updates.

**Suggested fix:** Add an explicit sub-step before Step 5's unchecked-item scan: "For each test-plan item, check whether the current session verified it (Playwright, CI, manual test). If verified, update the PR body to `- [x]` with `gh pr edit --body` before scanning for remaining unchecked items." This ensures the agent's own verification work is reflected in the PR description before the merge gate runs.
