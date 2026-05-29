---
class: principle
skill: wk-pr-review
date: 2026-05-29
---

# Review body antipatterns

- **Rule:** The review body must never contain: (1) blast-radius pre-judgment
  before arch-review runs, (2) process meta-commentary naming skills/tools
  invoked, (3) structurally-obvious findings ("no X blockers" when no code),
  (4) re-narration of what a bot already said, (5) bot-validation facts
  ("Validated N findings — all reproduced").
- **Why:** Each adds noise without value for the author; pre-judging scope also
  defeats arch-review, which exists to determine blast radius.
- **Where:** Phase 6 "Compose the review body" antipatterns list.
- **Reconciliation:** Reverses the prior "Collective acknowledgment is required"
  rule (Phase 5 + Compose) — a confirmed bot finding is surfaced by its
  substance only, never as a confirmation fact.
