---
skill: wk-jira
date: 2026-11-20
type: correction
severity: medium
verified-against-source: yes
---

The ticket key was in the session-opening prompt, but the ticket sat in Backlog through PR creation and approval.

**What happened:** The workflow ran end to end (commit, PR, ready, CI green, approval) but never ran the claim
(Stage 2) or the In Review transition (Stage 4). The drift only showed up when the user asked "is the work done?".

**Root cause:** The workflow skill fired first and the Jira skill was never invoked. The "claim precedes Phase 1" rule
depends on the agent remembering to load the Jira skill.

**Suggested fix:** Make the workflow's Phase 1 and PR create/ready steps invoke the Jira skill whenever a key is present,
and check live ticket status at every PR state change.
