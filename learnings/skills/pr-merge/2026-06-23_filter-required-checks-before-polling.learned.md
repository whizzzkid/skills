---
skill: wk-pr-merge
date: 2026-06-23
type: gap
severity: medium
---

In Step 2 (CI verification), filter check results to only required checks before polling for completion.

**What happened:** Step 2's CI polling loop fetched all checks and waited for non-required ones (security scanners, dependency checkers) to finish. Non-required checks often queue indefinitely, unnecessarily delaying the merge. User corrected: "that check is not required, just merge it."

**Root cause:** The polling loop used `gh pr checks --json name,state` without filtering on `required` field. Required and non-required checks are conflated, causing the step to wait for noise checks that do not gate the merge.

**Suggested fix:** In Step 2, immediately after fetching check results, filter to `required == true` only: `gh pr checks {number} --json name,state,required | jq '.[] | select(.required == true)'`. Only poll for completion on required checks. Report non-required checks as informational, not blockers.
