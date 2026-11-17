---
class: principle
---

# Split the carry-over index before dispatching rechecks

- **Rule** — Never hand every gathering agent the whole prior-page carry-over index with an open-ended "re-check your
  items". Pre-split it by domain, order each subset oldest/highest-priority first, and state an explicit item cap that
  fits the contract's word cap. An over-cap subset gets an extra agent for that domain; any item still unchecked keeps
  its prior text tagged "not reverified", never rendered as checked.
- **Why** — An agent given ~150 items verified a handful before exhausting its budget and reported the rest unchecked,
  so most older items kept stale text. Open-ended verification spends the budget wherever the agent starts; a
  priority order makes the cap cut the tail, not the head.
- **Where** — `SKILL.md` start Stage 2 (carry-over split bullet, applies to every gather incl. `end` and rollover);
  `references/missed-end-rollover.md` Shared gather part C; sibling `README.md` Features.
