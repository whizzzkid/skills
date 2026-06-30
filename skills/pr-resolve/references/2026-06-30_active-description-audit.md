---
class: principle
---

- **Rule:** Actively read the current PR description and diff it against branch
  state (commits, file list, test plan, CI) during Step 3, before triaging
  reviewer comments. Inject any staleness or missing-section finding as
  `surface: agent_observation`. Never rely on passively noticing drift.
- **Why:** When the visible work (resolving threads) feels complete, the
  agent-observed-drift and post-push body-sync rules are easy to skip. An explicit
  read forces the description to always be audited, not only when a reviewer flags it.
- **Where:** Step 3 agent-observed drift.
