---
skill: wk-sitrep
date: 2026-06-09
type: gap
severity: high
---

Cross-validate live.md items against external systems before assuming 0 completions at end-of-day.

**What happened:** `end` read live.md, found 0 `data-done="true"` items (only the morning's auto-action), and proceeded to treat everything as uncompleted. In reality the user completed many items during the day without checking them off in the browser.

**Root cause:** The skill only reads `data-done` attributes from live.md to determine done vs pending. It does not cross-check against GitHub (merged PRs), Jira (resolved tickets), Calendar (attended meetings = prep items done), or Slack (replied threads). Items the user actioned without toggling the checkbox are silently carried forward as open.

**Suggested fix:** In Stage 1 of `end`, after reading live.md, run a cross-validation pass using data from the parallel agents (GitHub merges, Jira status changes, attended calendar meetings, resolved Slack threads). For each `data-done="false"` item, check whether external state shows it as completed. Surface the candidates to the snapshot as done rather than pending. Explicitly note in the summary how many items were detected-done vs user-checked-done.
