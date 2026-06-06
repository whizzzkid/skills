---
skill: wk-goodmorning
date: 2026-04-24
type: gap
severity: medium
---

Today's Priorities section lacks links to source threads / docs even when the underlying items (Slack, GitHub, Jira, Gdocs, Zoom) have them available in the upstream sections.

**What happened:** The orchestrator wrote the "Today's Priorities" list in both morning.md and morning.html as plain text labels (e.g. "Tuong's weekly AI share doc — contribute TODAY", "Fresh Eyes rate limit rollout decision (pool of apps vs gitmirror)") — even though the underlying Slack threads, meeting Zoom URLs, and Google Doc URLs were already present in the agent outputs and in other sections of the same brief. User had to click back and forth between the Priorities list and the Slack/Calendar/GitHub sections to find the source link for each priority.

**Root cause:** The 2c HTML template and 2b markdown template in wk-goodmorning specify that priorities appear as a numbered list but do not require links to the source artifacts. The orchestrator preserves links inside the per-section cards (Slack, GitHub, Jira, Email, Calendar) but treats the Priorities list as a summary — paraphrased titles only. The Priorities list is the highest-traffic section (it is what the user scans first and returns to throughout the day), so paraphrased-only content creates extra clicks exactly where it hurts most.

**Suggested fix:** Add a rule to Stage 2b and 2c: every priority item that maps to an artifact in another section MUST carry the corresponding source link(s) inline. Where an item has multiple relevant artifacts (e.g. a PR + the Slack thread requesting review + a design doc), include all of them as inline `[label](url)` / `<a>` chips separated by ` · `. Synthesized / internal priorities (e.g. "Adjust Wish system prompt") that have no external artifact are exempt. Link categories to surface:

- Slack threads / DMs (always — if the priority came from a Slack ping)
- GitHub PRs / issues
- Jira tickets
- Calendar Zoom URLs (for time-blocked priorities)
- Google Doc / Drive URLs (for doc-based asks)
- Buildkite / Datadog / external tool URLs when the priority references them

Apply this retroactively to any Priorities list rendered after Stage 2 — never let a priority appear without its origin link when one exists.
