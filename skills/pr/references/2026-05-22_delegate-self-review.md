---
class: principle
date: 2026-05-22
source: learnings/skills/wk-pr/2026-05-22_self-review-interrupted-pending-review.md
---

- **Rule:** Always delegate self-review to `wk-self-review` via the Skill tool; never compose inline review comment payloads from `wk-pr` or call `gh api repos/.../pulls/{n}/comments` directly.
- **Why:** Raw inline-comment POST publishes immediately and bypasses the pending-review human-in-the-loop checkpoint (`POST /pulls/{n}/reviews` with `event: PENDING`, then user-approved submit) enforced by `wk-self-review`.
- **Where:** Step 4 (Once CI is Green) HARD RULE — never compose inline comment payloads directly from `wk-pr`.
