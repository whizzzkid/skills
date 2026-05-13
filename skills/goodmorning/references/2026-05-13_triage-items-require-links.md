---
date: 2026-05-13
slug: triage-items-require-links
---

- **Rule:** Every interactive triage item must carry a clickable URL to the underlying artifact; skip rather than present a linkless item.
- **Why:** Bare summaries force the user to context-switch (search Slack/Gmail/GitHub) before answering, defeating the purpose of a triage dashboard.
- **Where:** Stage 2a "Presentation format" HARD RULE; subagent contract `url` field; per-group link sources in `triage-link-sources.md`.
