---
skill: wk-self-review
date: 2026-11-20
type: gap
severity: low
verified-against-source: n/a
---

A pending self-review was still a draft when the user merged the PR, so the notes went public only after merge.

**What happened:** The self-review was staged as pending and re-staged after review fixes; the merge happened outside the agent, which skipped the Step 4.5 merge-gate submission.

**Root cause:** Step 4.5 only fires when the agent performs the merge; a user-performed merge never triggers it.

**Suggested fix:** When handing a ready PR to the user, state that the pending self-review must be submitted before merge, or submit it at the ready-for-review hand-off once CI and the review gate are clear.
