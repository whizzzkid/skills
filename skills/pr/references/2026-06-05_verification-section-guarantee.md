---
class: principle
date: 2026-06-05
---

- **Rule:** After populating a repo PR template, guarantee a
  Testing/verification section exists; append `## Testing` with concrete
  checks run when the template has none.
- **Why:** Repo templates without a verification section ship PRs with
  no record of how the change was exercised — a recurring
  description-check bot flag that forces a second cycle.
- **Where:** Step 2, "Resolve PR Body Template" → "When using a repo
  template" bullets (Guarantee a verification section).
