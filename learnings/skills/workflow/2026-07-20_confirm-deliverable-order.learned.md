---
skill: wk-workflow
date: 2026-07-20
type: correction
severity: low
---

Confirm the ordering of bundled deliverables before starting the first one.

**What happened:** A prompt bundled two deliverables (implement a fix + produce a hand-off doc). The agent began moving toward implementation; the user interrupted to say the doc should come first.

**Root cause:** The Continuity Rules enumerate deliverables but do not require confirming their *sequence* when a multi-item prompt leaves order implicit.

**Suggested fix:** In the Continuity Rules, when a prompt lists multiple deliverables, enumerate them AND their execution order; when order is ambiguous, state the intended sequence in one line before the first write-action so the user can redirect cheaply.
