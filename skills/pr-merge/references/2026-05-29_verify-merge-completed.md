---
class: principle
skill: wk-pr-merge
date: 2026-05-29
---

# Verify the PR actually merged before declaring success

- **Rule:** After the merge command, poll `gh pr view --json state` until
  `MERGED` or a ~60s timeout; never declare "Merge complete" while state is
  `OPEN`.
- **Why:** `gh pr merge --auto` and merge-queue repos return success while the
  PR is only *queued*. An immediate check returns `OPEN`; declaring success then
  conflates "queued" with "merged" and logs a null SHA.
- **Where:** Step 6 — HARD RULE + poll loop; on timeout, re-fetch blockers
  (unresolved threads / failed checks / changes requested) and stop before
  Step 7.
