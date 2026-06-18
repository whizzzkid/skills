---
class: principle
---

**Rule:** Check off PR-body test-plan checkboxes (Step 4.2 sync) as a blocking precondition for `gh pr ready` — not an after-thought.

**Why:** The CI-green step instructs syncing the description and ticking satisfied items, but it is easy to skip in the rush to `gh pr ready`. Unchecked boxes on a PR marked ready read to reviewers as work not done. Re-violation of the existing Step 4.2 rule → escalated to a HARD RULE gate in Step 5.

**Where:** Step 5, immediately before the `gh pr ready` call.
