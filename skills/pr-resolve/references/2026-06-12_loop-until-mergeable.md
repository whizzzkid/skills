---
class: principle
date: 2026-06-12
skill: wk-pr-resolve
---

- **Rule:** After CI passes, re-fetch all three comment surfaces and loop;
  the terminal condition is "CI green AND zero unresolved threads", not "CI
  green". Never return control mid-loop because CI happened to pass.
- **Why:** Late-arriving bot comments from the CI run are left unaddressed if
  the agent stops at CI-green; the contract is loop-until-mergeable.
- **Where:** Step 9.5 loop-exit rule (already covered) — recurred, so escalated.
- **Escalation:** Important (recurred 2026-06-12) — bumped exit rule to notch 2
  (`**Important:**`) per the wk-sharpen re-violation ladder. Next → "Very important".
