---
skill: wk-pr
date: 2026-06-10
type: correction
severity: medium
---

Check whether the source branch is already merged before targeting it for a follow-up PR.

**What happened:** Agent was about to create a PR against a feature branch that had already been merged to main. The follow-up fixes were intended for the next review cycle, so the correct base was main, not the merged branch.

**Root cause:** When a follow-up PR is created to address issues found in a code review, the skill assumed the reviewed branch was still the target. It did not check whether that branch was merged before proceeding.

**Suggested fix:** Before creating any PR that references a prior PR or branch as its base, run `gh pr view --json state --jq .state` on that branch. If `state == "MERGED"`, default the new PR base to the default branch (main) and notify the user. Never push to a merged branch.
