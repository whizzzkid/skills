---
class: principle
date: 2026-06-10
skill: wk-workflow
severity: high
---

- **Rule:** Session resumption (context compaction, window rollover,
  "continue where we left off") requires invoking the workflow before any
  write action, exactly like a fresh task.
- **Why:** Workflow activation status does not carry across the resume
  boundary; identifying pending work and executing it without re-invoking
  the workflow skips every gate.
- **Where:** Mandatory Activation — "Session resumption is a fresh start".
