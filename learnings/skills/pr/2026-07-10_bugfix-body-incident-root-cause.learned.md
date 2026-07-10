---
skill: wk-pr
date: 2026-07-10
type: gap
severity: medium
---

A bugfix PR body should proactively narrate the concrete triggering-incident root cause, not just the abstract defect.

**What happened:** The PR fixed an auto-approval bug that a specific real PR had exposed. The initial body described the general mechanism (dismissed approvals lose their state) but not the concrete chain of events on the triggering PR. The user had to explicitly ask "why did the original PR not get auto-approved? add that to the description."

**Root cause:** wk-pr's body composition derives "what/why" from the diff, but a bugfix's most useful "why" for reviewers is the specific incident that surfaced it — who did what, which API returned what, why the gate misfired. That incident narrative is not in the diff and gets omitted.

**Suggested fix:** When the PR is a bugfix triggered by a specific incident (a linked PR/issue/outage), the `## Why` section must include the concrete step-by-step of how the incident occurred, not only the abstract defect class. Treat "explain why the triggering case failed" as a required bugfix-body element.
