---
skill: wk-sitrep
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

Auto-launched pending-draft PR reviews are rendered as done once created, but nothing re-checks whether the user ever submitted them — so unsubmitted drafts silently pile up across multiple days.

**What happened:** A prior `start` run auto-launched pending-draft reviews on several PRs and rendered them as done ⚙️ Auto-Actions. On a later `start` run, re-querying GitHub showed those reviews were still `PENDING` (never submitted) days later, and one from over a week earlier was in the same state. None of this had resurfaced anywhere in `live.md` in the interim — it only came to light because this run's GitHub gathering agent was explicitly told to re-verify those specific PR numbers.

**Root cause:** The auto-review Stage 7 mechanics only render the launch action as done; there is no follow-up step that treats "pending draft not yet submitted" as its own carry-over category. A `PENDING` review is functionally an open TODO for the user (submit or discard it), but the skill has no query that surfaces it again unless an agent happens to be pointed at that exact PR number.

**Suggested fix:** Add a check in the GitHub gathering agent's standing instructions: search the user's own reviews for `state: PENDING` across the org (not just re-verifying specific known PRs) and surface every result as an ASAP item until submitted or explicitly dismissed. This turns a one-off manual catch into a standing sweep.
