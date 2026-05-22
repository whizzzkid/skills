---
class: principle
date: 2026-05-22
source: learnings/skills/wk-pr/2026-05-22_forgot-mark-ready-after-iterations.md
---

- **Rule:** Every push to an open draft PR carries an implicit commitment to re-run the adversarial gate and `gh pr ready` once CI is green; iteration rounds (refactor, dedup, follow-up commits) do not reset that commitment. Valid pre-ready exits: CI failing after 3 fix-loop attempts, open `blocked` verdict, explicit user pause.
- **Why:** Agent treated "pushed code" as task complete and left the PR in draft across multiple refactor rounds — user had to prompt "why didn't you mark this ready?"
- **Where:** Step 5 (Mark Ready) HARD RULE — never end a turn with a draft PR whose work is done.
