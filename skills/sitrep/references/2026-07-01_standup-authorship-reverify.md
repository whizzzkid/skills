---
class: principle
---

**Rule:** At standup compile, re-confirm each PR's `author.login` via `gh`
(`gh search prs --author @me --merged --merged-at <range>`) — never trust
carryover tracking or agent-reported attribution. Render one bullet per win
(not a comma-joined line) and append each PR's bare URL.

**Why:** Carried-over "your PRs" tracking lists include PRs the user only
reviewed or watched; trusting that attribution ships other people's merges as
the user's own wins. The standup lives in a `<pre>` copy block where markdown
links do not render, so bare URLs are what auto-link when pasted into Slack.

**Where:** wk-sitrep Stage 4b (Standup snippet → Yesterday).
