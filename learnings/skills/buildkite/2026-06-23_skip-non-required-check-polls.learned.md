---
skill: wk-buildkite
date: 2026-06-23
type: gap
severity: medium
---

When polling CI status before merge, skip non-required checks that are queued or still running — only wait for required checks.

**What happened:** A non-required check (boostsecurity) was still queued while all required checks passed. The agent polled until timeout waiting for it to complete, delaying the merge unnecessarily.

**Root cause:** The CI polling loop did not filter on the `required` field — it waited for *all* checks to finish, not just the ones that gate the merge. Non-required/informational checks (security scanners, dependency checkers) often queue indefinitely and should not block the workflow.

**Suggested fix:** In `wk-pr-merge` Step 2, after fetching check states, immediately skip any check where `required == false` (or the field is absent). Only poll/wait for checks where `required == true`. Patch: `gh pr checks --json name,state,required | jq '.[] | select(.required == true)'` before polling.
