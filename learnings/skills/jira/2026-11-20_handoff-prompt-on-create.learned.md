---
skill: wk-jira
date: 2026-11-20
type: gap
severity: medium
verified-against-source: n/a
---

Every ticket creation should come with a ready-to-paste hand-off prompt for an agent.

**What happened:** The agent created a follow-up ticket and reported only its key and summary. The user then had to ask
separately for a prompt another agent could pick it up with.

**Root cause:** Manual ticket operations stop at "create and report". Nothing says to package the ticket for hand-off.

**Suggested fix:** Add to Manual ticket operations: after every create, present a fenced hand-off prompt in the same
response. It should give the ticket key, the problem with the facts already verified, the acceptance criteria, the
starting files, the constraints and gates (env/container rules, required checks), what is out of scope, and an opening
instruction to start the dev workflow skill.
