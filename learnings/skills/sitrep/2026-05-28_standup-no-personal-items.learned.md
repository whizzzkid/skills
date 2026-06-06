---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: high
---

The standup snippet must only contain work items ready to share with the full team; personal or sensitive items belong in the dashboard only.

**What happened:** The standup included items like "QPR performance conversation window closes today" and "Reply Lucy Fox farewell" — personal administrative actions that are not appropriate for a team standup channel. These appeared because the skill promoted all high-priority items directly to the standup without filtering for team-shareability.

**Root cause:** The skill's standup source-mapping rule ("Today → top 3-4 🔥/⚠️-flagged items") does not distinguish between items that are appropriate for public team posting vs items that are personal or sensitive (QPR conversations, farewell replies, candidate interviews, personal HR actions, Lattice tasks).

**Suggested fix:** Add a standup filter rule before source-mapping: "Exclude from the standup any item that is (a) a hiring/interview action, (b) a personal HR/performance/QPR action, (c) a personal communication (farewell replies, DMs), or (d) any item the user has not yet decided to share publicly. The standup is a public team artifact; the morning dashboard is private. When in doubt, omit."
