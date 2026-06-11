---
class: principle
---

- **Rule** — Before debugging a PR's CI failure, verify the branch is one the
  agent created this engagement; stop and tell the user when it is not.
- **Why** — The agent began debugging an unrelated PR the user never assigned;
  "PR #N is failing" is a request, not authorization to touch any branch.
- **Where** — New "HARD RULE: investigate only your own branches" section after
  When to Use.
- **Source** — materialized from global memory `feedback_only_own_prs`.
