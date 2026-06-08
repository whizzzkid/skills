---
skill: wk-workflow
date: 2026-06-06
type: correction
severity: medium
---

Run every test plan verification command before marking its checkbox — never leave a box unchecked just because it wasn't run yet.

**What happened:** After CI passed, the agent checked off 3 of 4 test plan items and left one unchecked with the rationale "I didn't explicitly run this." The user had to ask why it wasn't checked, prompting the agent to run the command immediately — which passed in seconds.

**Root cause:** The agent treated "I happened to run this earlier" as the gate for checking a box, rather than "I must run this now." A box that can be verified must be verified — deferring to the user to notice the gap is a workflow failure.

**Suggested fix:** After CI goes green, loop over every unchecked test plan item and run its verification command before updating the PR description. The rule is: if the command can be run locally, run it; only leave a box unchecked when verification is genuinely impossible (e.g., requires a live production environment or third-party credentials not available).
