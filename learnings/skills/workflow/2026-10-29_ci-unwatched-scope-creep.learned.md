---
skill: wk-workflow
date: 2026-10-29
type: correction
severity: high
verified-against-source: n/a
---

Reported a phase PR as done without watching CI, and over-built the phase beyond its stated deliverable.

**What happened:** After opening a stacked draft PR, the agent summarized results instead of entering the CI fix loop;
CI was red. The phase also shipped next-phase scaffolding (reconcile job, source-attribution fields, extra config keys,
columns only a later phase uses) that the user had not asked for.

**Root cause:** Treated "PR created" as a terminus despite Phase 6, and let a multi-phase spec pull later-phase design
into the current phase's diff.

**Suggested fix:** Phase 5 exit gate: after any PR create/push, start the CI watch in the same turn and do not report
completion until green or a diagnosed failure is surfaced. Phase 2: scope each phase PR to exactly the user's stated
deliverable for that phase; anything a later phase needs waits for that phase.
