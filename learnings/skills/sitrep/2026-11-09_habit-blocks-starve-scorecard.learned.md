---
skill: wk-sitrep
date: 2026-11-09
type: gap
severity: medium
verified-against-source: n/a
---

Auto-booked interview scorecard found no same-day slot because auto-scheduled habit blocks count as busy

**What happened:** The interview scan treats every non-declined event as busy. The interview was followed by a meeting
and then a multi-hour auto-scheduled "wrap up" habit block through the end of the working day, so no 45-minute window
existed and the scorecard block could not be booked. The skill only says to flag a warning.

**Root cause:** The busy rule makes no distinction between fixed meetings and flexible habit/focus blocks that the
user would readily displace for a scorecard.

**Suggested fix:** When no free window exists, offer the earliest slot that overlaps only a flexible habit block (named
in the warning) as the proposed placement, still never shortening the block; keep the warning open work for the user.
Also: a Greenhouse scorecard in `draft` status is not submitted; render it as still owed.
