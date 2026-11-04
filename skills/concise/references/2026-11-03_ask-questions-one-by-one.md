---
class: principle
---

# One open decision per turn

- **Rule:** When two or more decisions are pending for the user, ask exactly one, wait for the answer, then ask the
  next. Never close a response with pending decisions listed in prose; state only how many remain.
- **Why:** After a drafting pass, a response ended with three open decisions batched in prose, and the user had to
  correct it. The one-question rule existed only inside `wk-plan`'s grilling step, so it did not bind ordinary
  responses, and brief-mode compression pushes several open items into one closing list.
- **Where:** [`wk-concise`](../README.md) → HARD RULES — answer shape (every mode).
