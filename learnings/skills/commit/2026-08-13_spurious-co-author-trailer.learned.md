---
skill: wk-commit
date: 2026-08-13
type: correction
severity: medium
verified-against-source: n/a
---

Do not add Co-authored-by trailer when agent IS the git user

**What happened:** Agent added `Co-authored-by: {user}` to every commit even
though the git config user and the PR author were the same person. The trailer
is only meaningful when the committer differs from the PR author (e.g. agent
committing on someone else's PR). User corrected: "the /wk-pr skill tells you
to only have assisted-by annotation nothing else."

**Root cause:** Misapplied `wk-pr-resolve` Hard Rule 9 without checking
`$CURRENT_USER == $PR_AUTHOR`. When they match, the commit already carries the
correct author via git config — adding a Co-authored-by for the same person is
redundant and confusing.

**Suggested fix:** Before adding any `Co-authored-by` trailer, compare
`$CURRENT_USER` (from git config) with `$PR_AUTHOR` (from `gh pr view`). Skip
the trailer entirely when they match. Only `Assisted-by: Claude` should appear
as a standard trailer on all agent-produced commits.
