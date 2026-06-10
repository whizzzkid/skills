---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

Never put multiple links in the same standup bullet — one link per bullet, always.

**What happened:** Grouped bullets like "Merged #NNN · #NNN · #NNN · #NNN" and "Merge Party — {repo} #NNN #NNN #NNN #NNN #NNN" had multiple PR links on a single line. When pasted into Slack, the visual noise and lack of structure made it hard to click individual items.

**Root cause:** The skill allows grouping related items into one bullet for brevity, but does not prohibit multiple links per bullet. Grouping multiple linked items on one line is always worse than sub-listing them.

**Suggested fix:** Add a HARD RULE to the standup spec: "Each bullet may contain at most one external link. When multiple artifacts belong together (e.g. a set of merged PRs, a set of PRs to review), create a parent bullet describing the group and sub-list each artifact as its own child bullet with its single link."
