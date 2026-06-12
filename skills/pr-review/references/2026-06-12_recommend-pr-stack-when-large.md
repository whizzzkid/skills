---
class: principle
---

# Recommend a PR stack when the PR is large

- **Rule** — When a PR is large (several hundred lines, or many unrelated
  concerns), recommend the author split it into multiple PRs and stack them,
  sketching the natural split lines; frame as a suggestion, not a demand.
- **Why** — Large PRs are hard to review well; a stack keeps each unit small
  and reviewable. The prior rule said "smaller PRs" but never named stacking.
- **Where** — Phase 1 "Collect context" captures change size; Phase 6
  "Compose the review body" too-large bullet recommends the stack.
