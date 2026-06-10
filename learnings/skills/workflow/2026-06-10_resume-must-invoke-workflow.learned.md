---
skill: wk-workflow
date: 2026-06-10
type: correction
severity: high
---

Resuming a compacted session is still a development task — wk:workflow must be invoked first.

**What happened:** A session resumed mid-task (context was compacted from a prior run). The agent identified the pending work (patch-replay, push), executed it, and declared the branch ready — without invoking wk:workflow. The user had to prompt "why did you not run the full workflow?"

**Root cause:** The CLAUDE.md rule says "STOP. Before any development task, invoke wk:workflow" but the agent treated resuming a compacted session as "continuing work already in progress" rather than as a new development task requiring the workflow gate.

**Suggested fix:** Add an explicit rule to wk-workflow (or CLAUDE.md) stating that session resumptions — whether from context compaction, a context window rollover, or a "continue where we left off" prompt — always require wk:workflow to be invoked before any write action, just like any fresh start. Continuation context does not carry over workflow activation status.
