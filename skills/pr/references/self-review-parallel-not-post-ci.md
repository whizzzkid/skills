---
class: principle
---

**Rule:** Invoke `wk-self-review` the moment `gh pr create` returns — in parallel with launching the CI poll — never serially after CI turns green. Treat deferral-until-CI as a blocker-equivalent.

**Why:** The intuitive "CI green → then do review work" mental model is wrong for self-review: CI takes minutes, and staging the self-review draft in that window puts the PR closer to ready when CI finishes. Deferring self-review until post-CI is a recurring violation — a distilled learning saying "post in parallel" failed to propagate back into live behavior, so the rule was escalated to a HARD RULE.

**Where:** Step 3.2 in `SKILL.md` — the parallel-timing rule now carries an explicit HARD RULE ("self-review runs in parallel, never after CI") alongside the existing pending-review-payload HARD RULE.
