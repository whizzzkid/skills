---
skill: wk-sharpen
date: 2026-05-01
type: correction
severity: medium
---

Don't stall the improve run waiting for git push — commit continuously, push is the user's gate.

**What happened:** After each commit, the agent stopped and asked the user to push before proceeding to the next phase, treating push as a required synchronization point.

**Root cause:** wk-commit instructs "push after every commit" and wk-workflow's terminal gate checks for a clean tree + pushed commits. The agent interpreted this as a blocking dependency between phases.

**Suggested fix:** In improve mode (and any multi-phase sharpen run), commits are incremental checkpoints — push is a single user-controlled gate at the end. After committing, proceed immediately to the next phase without pausing. Only report the final push status once all phases are done.
