---
skill: wk-sitrep
date: 2026-07-01
type: correction
severity: high
---

Standup "Yesterday" wins were built from carried-over "your PRs" tracking data without re-verifying GitHub authorship, shipping two other people's merged PRs as the user's own.

**What happened:** At `start`, the standup Yesterday block listed the day's merged PRs as the user's wins. Two of them were authored by other people (a teammate `{author}` and a bot-adjacent account) — they had only appeared in a prior day's "your PRs / to review" tracking list. They were rendered as the user's merges until the user caught it. Separately, all merged PRs were crammed into one bullet line instead of one bullet per win.

**Root cause:** The standup compile trusted the gathering agent's attribution and the carried-over tracking list, neither of which re-confirms `author.login`. Tracking lists mix "your PRs" and "PRs to review", so carryover attribution is unreliable for the authorship filter (author / co-author / primary-approving-reviewer only).

**Suggested fix:** Before rendering any PR as a Yesterday win, confirm authorship at compile time with `gh pr view <pr> --json author,mergedAt` (or `gh search prs --author @me --merged --merged-at <range>` to enumerate) — never infer from carryover or agent-reported attribution. Render one bullet per win, not a single comma-joined line. Append each PR's bare URL to its bullet: the standup lives in a `<pre>` copy-to-clipboard block, so markdown links do not render — bare URLs are what auto-link when pasted into Slack. The rendering contract's "omit items with no canonical URL / every item needs a link" rule applies to standup PR lines too, not just the checkbox spans.
