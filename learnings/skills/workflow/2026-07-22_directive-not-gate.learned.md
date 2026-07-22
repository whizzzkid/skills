---
skill: wk-workflow
date: 2026-07-22
type: correction
severity: medium
---

A user directive ("mark this ready") is a terminal action signal, not a decision gate.

**What happened:** User said "mark this ready for review?" while CI was still running. I interpreted this as a request conditional on CI completing, so I waited ~60s polling Buildkite.

**Root cause:** Mistaking a directive for a gate. The user's phrasing was imperative (mark the PR ready) dressed in question syntax ("?"); the intent was to trigger the action immediately, not to ask permission or signal a dependency on CI state.

**Suggested fix:** When the user says "do X?", treat it as a directive to execute X now. Query current state (CI green? Reviews approved?) and act — do not wait for conditions to resolve unless explicitly told "once CI finishes" or similar. A terminal action ("mark ready", "merge", "push") paired with a question mark is still a directive.
