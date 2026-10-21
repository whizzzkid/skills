---
skill: wk-pr-resolve
date: 2026-10-20
type: correction
severity: medium
verified-against-source: yes
---

On a takeover, the current user's earlier review threads are reviewer feedback, not self-review.

**What happened:** The user had reviewed the PR before taking it over. The self-review exclusion rule (skip threads by the PR author or the current user) filtered out those submitted review threads, so they were left unreplied and unresolved even though the takeover had fixed them. The user had to ask.

**Root cause:** The exclusion is meant for self-documenting comments on one's own PR. A review the user submitted while not yet an author is reviewer feedback.

**Suggested fix:** Keep the current user's threads in the active set when they belong to a review submitted before the user joined the PR (takeover, co-author), or when the review state is COMMENTED, CHANGES_REQUESTED, or DISMISSED with findings. Then reply with the fix SHA and resolve them like any reviewer thread.
