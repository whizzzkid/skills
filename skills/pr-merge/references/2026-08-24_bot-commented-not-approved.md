---
class: principle
---

**Rule:** When `reviewDecision` stays `REVIEW_REQUIRED` after all bot threads
are resolved and the bot's latest review is `COMMENTED` (not `APPROVED`), push
an empty commit to trigger bot re-evaluation. Bots re-evaluate on push events,
not on thread resolution state changes.

**Why:** Resolving all bot threads does not trigger the bot to post a new
`APPROVED` review. The `COMMENTED` review type never changes `reviewDecision`
to `APPROVED`. A new push event is required to trigger the re-evaluation cycle.

**Where:** `SKILL.md` → Step 3 → `reviewDecision == "REVIEW_REQUIRED"` handling.
