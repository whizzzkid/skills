---
skill: wk-goodmorning
date: 2026-05-05
type: gap
severity: high
---

Always append a Slack standup snippet at the end of every morning brief

**What happened:** User had to manually request a standup snippet after the morning brief was generated. The brief had all the source data (evening.md achievements → Yesterday, priorities → Today, blocker items → Blockers) but didn't distill it into a copy-paste-ready format.

**Root cause:** The skill has no standup snippet output step. The user's daily workflow includes posting a standup to their team Slack channel every morning, so this is a consistent need — not a one-off request.

**Suggested fix:** Add a "## Standup Snippet" section at the end of both `morning.md` and the HTML dashboard (as a copyable card). Format:

```
- 👈🏽 Yesterday:
  - [item text] [bare URL] [bare URL if multiple]
- 👉🏽 Today:
  - [item text] [bare URL]
- ✋🏽 Blockers:
  - [item text] [bare URL]
```

**CRITICAL — Slack link formatting:** Do NOT use markdown `[text](url)` syntax — Slack does not render it when copy-pasted. Use bare URLs only (Slack auto-linkifies them). Include the URL inline after the item text, separated by a space. If an item has multiple artifacts (e.g., two PRs), list both URLs space-separated on the same line.

Source mapping:
- Yesterday → evening.md `## Achievements` (Code & PRs + key meetings, 3-4 highest-impact items)
- Today → morning.md `## Today's Priorities` (top 3-4 🔥 items, time-sensitive first)
- Blockers → any item flagged ⚠️ or containing "BLOCKED" / "conflict"

Every bullet must include at least one bare URL linking to the primary artifact (PR, Jira ticket, Slack thread). Items with no external artifact (e.g., a meeting debrief) may omit the URL.

HTML card should have a one-click "Copy to clipboard" button that copies plain text with bare URLs (not HTML).
