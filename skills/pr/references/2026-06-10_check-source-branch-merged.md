---
class: principle
date: 2026-06-10
skill: wk-pr
---

- **Rule:** Before targeting an explicitly-named base branch (a `wk-pr` base
  argument, or a reviewed branch chosen for a follow-up PR), check
  `gh pr view <branch> --json state --jq .state`; retarget to the default
  branch when `state == "MERGED"` and notify the user.
- **Why:** Auto base-detection scans only `--state open` PRs, so a merged base
  never enters the candidate set — the explicit-base path would otherwise push
  a follow-up onto a dead branch.
- **Where:** Step 1, "Merged-base check" subsection (after Draft-base override).
