---
class: principle
---

- **Rule:** After transitioning a ticket to a working state, assign the active sprint (JQL `sprint in openSprints()`), resolving the sprint field id from metadata rather than assuming a fixed `customfield_*`.
- **Why:** A ticket with no sprint lands in the backlog — invisible on the sprint board and absent from velocity tracking.
- **Where:** New "Active-sprint assignment" subroutine, invoked from Stage 2 (In Progress) and Stage 4 (In Review).
