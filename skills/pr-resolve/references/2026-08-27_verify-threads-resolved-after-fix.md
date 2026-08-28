---
class: principle
---

- **Rule:** After resolving threads, re-query the unresolved-threads list and assert every thread whose finding was fixed in this round is now resolved. A non-empty result for an addressed finding is a failure, not a report item.
- **Why:** Fixes were pushed but resolve mutations were skipped or silently failed; the user had to ask whether the resolve step ran at all.
- **Where:** Step 8 inline rule; post-push-finalization.md verification sub-step.
