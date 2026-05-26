---
skill: wk-pr-review
date: 2026-05-26
type: pattern
severity: medium
---

User prefers auto-post at Phase 6 — no A/B/C prompt needed.

**What happened:** Phase 6 presented an A/B/C choice and waited for user confirmation before posting the pending review.

**Root cause:** The skill's hard rule ("never post without explicit confirmation") is designed for safety, but this user edits inline comments in the GitHub UI and finds the terminal prompt redundant friction.

**Suggested fix:** After presenting the Phase 5 comment summary, proceed directly to POSTing the pending review without the A/B/C gate. Still print the `html_url` and "Submit on GitHub when ready." The user can still request changes by saying so before the summary is shown.
