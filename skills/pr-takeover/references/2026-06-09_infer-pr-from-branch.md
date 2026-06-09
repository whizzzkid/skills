---
class: principle
skill: wk-pr-takeover
date: 2026-06-09
severity: medium
---

- **Rule:** When no PR argument is given, infer the target from the current
  branch (`gh pr view --json number --jq .number`) and confirm with the user
  before falling through to the explicit prompt.
- **Why:** Prompting for a PR number the branch already discloses is needless
  friction — the open PR on the current branch is the implied target.
- **Where:** Step 1: Parse Arguments, branch-inference fallback before the
  "Which PR are you taking over?" prompt.
