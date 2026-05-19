---
class: principle
date: 2026-05-19
---

- **Rule:** Before surfacing a "missing documentation / description-check"
  bot finding for consultation, grep the diff + `docs/specs/`,
  `docs/plans/`, `docs/adr/`, and in-code design blocks for the called-out
  behavior; if covered, default to dismiss-with-reference.
- **Why:** Surfacing the consultation without first checking the repo
  forces the user to re-clarify what the agent could have found —
  the "missing" claim is often false.
- **Where:** Step 4 "Verify 'missing documentation' bot findings
  against repo docs".
