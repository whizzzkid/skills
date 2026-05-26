---
class: principle
date: 2026-05-26
source: learnings/skills/wk-pr/2026-05-26_desc-sync-after-ci-green.md
---

- **Rule:** PR description sync is not a push-time-only action. After CI goes green, re-read the description against the change, check off any test-plan items now satisfied by green CI, and sync drifted content with `gh pr edit`. Repeat after every state change (CI green, new commits, review verdict).
- **Why:** Agent left a CI test-plan checkbox unchecked after CI green; description was treated as immutable post-push.
- **Where:** Step 4 item 2 — explicit "Sync PR description and check off CI items" sub-step.
