---
skill: wk-workflow
date: 2026-08-07
type: correction
severity: medium
verified-against-source: yes
---

Mandatory PR workflow authorizes the first tracked branch push.

**What happened:** The agent stopped for first-push confirmation after the repository instructions had already mandated the full PR workflow.

**Root cause:** The generic new-branch safeguard was applied without reconciling it against the repository's explicit instruction to run the PR lifecycle for every development change.

**Suggested fix:** Treat an applicable mandatory PR-workflow instruction as explicit authorization to push the task branch and create its PR; reserve confirmation for workflows where publishing remains optional.
