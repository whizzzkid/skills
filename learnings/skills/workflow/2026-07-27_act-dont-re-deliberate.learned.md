---
skill: wk-workflow
date: 2026-07-27
type: correction
severity: medium
verified-against-source: n/a
---

Re-deliberating an already-diagnosed problem reads to the user as going in circles; once the fix target is known, edit it.

**What happened:** After establishing that a documented opt-in test mode had never
worked, the agent kept re-analysing whether to remove it, whether to repair it, and
which artifact "really" owned the defect — across several turns — instead of editing
the agent-instructions file that documented it. The user interrupted with "so create a
fix to edit the {file} instead? why are you going around in circles?". The same
session also drew "what are you waiting for?" after the agent reported a PR URL and
paused mid-lifecycle.

**Root cause:** The Autonomy Rules table enumerates situations where the agent must
act without asking, but every row is a *permission* case ("shall I commit?"). There is
no row for the *analysis* case: the agent has already identified the defect and the
file that carries it, and further reasoning adds no information. Restating the
tradeoffs feels like diligence, so nothing in the skill stops it.

**Suggested fix:** Add an Autonomy Rules row — "Defect diagnosed and the owning file
identified | Edit that file now | Re-state the tradeoffs a third time". Pair it with a
one-line stop condition: once a turn produces no new *facts* about the problem (no new
file read, no new command output), the next action must be a write, not more prose.
