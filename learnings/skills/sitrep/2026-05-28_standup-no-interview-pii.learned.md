---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: high
---

Never include candidate names, interview links, or hiring-pipeline details in the standup snippet.

**What happened:** The standup "Today" section included the interview candidate's full name, a CodeSignal live-interview URL, and a Greenhouse scorecard link. These are private hiring-pipeline details that must not appear in a team standup.

**Root cause:** The skill maps "Today's Priorities" directly to standup bullets without a privacy filter. Interviews are a priority but the underlying details (candidate identity, scoring links) are confidential.

**Suggested fix:** Add a standup privacy rule: "When a Today priority is an interview or hiring-related item, render it generically — e.g. 'L4 SE candidate interview 12pm' with no candidate name, CodeSignal URL, Greenhouse link, or scorecard reference. Never include PII or hiring-pipeline URLs in the standup snippet."
