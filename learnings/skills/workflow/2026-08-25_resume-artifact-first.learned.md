---
skill: wk-workflow
date: 2026-08-25
type: correction
severity: medium
verified-against-source: yes
---

Recover named handoff artifacts before inferring continuation from branch state.

**What happened:** The agent inferred that a resumed task was the current pull request lifecycle, but the user expected continuation from a plan stored outside the worktree.

**Root cause:** Session recovery inspected Git state and generic memory without first locating a concrete handoff artifact from the prior run.

**Suggested fix:** On ambiguous continuation requests, inspect the current workspace for plan and handoff files and ask for or recover their known location before selecting a workflow phase from branch state alone.
