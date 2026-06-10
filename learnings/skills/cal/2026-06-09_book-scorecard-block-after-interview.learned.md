---
skill: wk-cal
date: 2026-06-09
type: gap
severity: high
---

Book scorecard calendar block after interview — do not just add a checkbox.

**What happened:** Interview prep scan surfaced an upcoming candidate work session. Agent added "Block 15min post-session for Greenhouse scorecard" as a checkbox in live.md instead of creating an actual calendar event.

**Root cause:** Skill instruction covers interview prep scan and scheduling prep blocks, but does not explicitly require creating a post-interview scorecard calendar event. Agent treated it as a to-do item rather than an action to execute immediately.

**Suggested fix:** When the interview prep scan identifies an upcoming interview event, automatically create a **30–45 minute** calendar block titled "Scorecard — {Candidate Name}" immediately after the interview end time (same day, same calendar). Use the calendar MCP to create the event before writing live.md. Do not surface this as a checkbox — it should be an auto-action rendered as `data-done="true"` once booked. 15 minutes is not enough time to complete a Greenhouse scorecard.
