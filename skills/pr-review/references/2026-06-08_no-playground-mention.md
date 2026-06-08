---
class: principle
---

- **Rule:** In author-facing comments/review body, say "verified locally"
  (or "verified against upstream source") — never name the
  `.review-playground/` directory, playground scripts, or "experiment"
  artifacts.
- **Why:** The playground is internal scaffolding; naming it leaks agent
  internals that are meaningless to the PR author.
- **Where:** Phase 4 evidence-disclosure bullet (beside the "never disclose
  local environment state" rule).
