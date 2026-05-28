---
class: principle
date: 2026-05-28
source:
  - $WK_SKILLS_HOME/learnings/skills/goodmorning/2026-05-28_stale-lattice-carryover.md
severity: medium
---

- **Rule** — every carry-over item from a prior brief must be cross-checked against this run's live data before surfacing; drop ones the live source contradicts.
- **Why** — carry-overs decay (review cycles close, tickets close, deadlines pass) and contradicting the live state in the brief erodes user trust. Lattice items decay fastest because their state changes outside the agent's visibility.
- **Where** — wk-goodmorning Stage 2 HARD RULE block immediately after the "merge with `carry_over` dataset" step. Carry-overs without a domain source pass through with a freshness warning rather than getting silently dropped.
