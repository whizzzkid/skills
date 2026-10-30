---
skill: wk-workflow
date: 2026-10-30
type: correction
severity: medium
verified-against-source: n/a
---

A broken test environment halted implementation instead of only the verify phase.

**What happened:** In auto mode with an unambiguous imperative, the agent presented the plan, hit a package-registry
auth failure during dependency install, and stopped to ask the user — writing no code. The user had to ask why nothing
was implemented.

**Root cause:** The agent treated an environment blocker as a plan-level blocker. Credential failures block only
test/lint execution, not editing.

**Suggested fix:** In Phase 3's environment rule, state: an environment failure blocks only the gates that need it.
Implement and commit, then surface the blocker scoped to the unverified gates.
