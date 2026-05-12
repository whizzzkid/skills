---
name: user-touched-threads-followup
description: Narrow follow-up allowed on reviewer threads the current user has already replied to.
---

- **Rule:** On a non-self reviewer/bot thread where the current user has posted a
  reply, the agent may add one follow-up comment if a session fix changed the
  finding or a new uncovered item needs explicit callout.
- **Why:** A prior reply by the user signals engagement and scopes permission;
  the broader exclusion rule existed to prevent unsolicited comments on threads
  the user had not touched.
- **Where:** Hard Rule 8 in `pr-resolve/SKILL.md`. Still subject to Hard Rule 2
  (confirmation before posting) and Hard Rule 3 (no resolution from commenting).
