---
date: 2026-05-13
slug: pending-review-recheck-before-replies
---

- **Rule:** Re-run the Step 3 pending self-review check at the start of Step 8 before posting any reply.
- **Why:** A pending review submitted between Step 3 and Step 8 rejects every reply POST with HTTP 422; the single pre-flight is insufficient.
- **Where:** `Step 8 → Re-check pending self-review before replies` (HARD RULE) in `wk-pr-resolve` SKILL.md.
