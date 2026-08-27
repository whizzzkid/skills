---
class: principle
source: learnings/skills/pr-resolve/2026-08-27_read-blocking-finding-before-escalating-gate.md
---

# Read bot finding bodies before gate-level actions

**Rule:** When a bot review holds a PR at REVIEW_REQUIRED, ALWAYS fetch and
read the finding bodies before considering gate-level actions
(dismiss/override/wait). A bot that auto-approves on fix keeps the PR blocked
because there IS an unaddressed finding — the review state signals the finding,
not an independent gate.

**Why:** Agent treated a COMMENTED/REVIEW_REQUIRED bot review as a gate-state
problem, presenting the user three options (wait for infra, dismiss the review,
admin-override merge) without reading the bot's Major blocking finding. The bot
had posted a concrete fix; implementing it would have flipped the bot to
APPROVED automatically.

**Where:** Hard Rule 10, new sub-bullet — widens "evaluate each for
correctness" to mandate reading finding bodies before any gate-level action.
