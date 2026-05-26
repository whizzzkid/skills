---
class: principle
date: 2026-05-26
source: learnings/skills/wk-pr/2026-05-26_self-review-before-ci-poll.md
---

- **Rule:** Invoke `wk-self-review` immediately after `gh pr create` (before/in parallel with backgrounding the CI poll), not after CI green. CI takes minutes; staging the pending review in that window means the PR is closer to ready when CI finishes.
- **Why:** Sequential flow (CI poll → self-review) wasted the CI-wait window; parallel flow uses it.
- **Where:** Step 3 item 2 reordered: self-review is now item 2, CI poll is item 3.
