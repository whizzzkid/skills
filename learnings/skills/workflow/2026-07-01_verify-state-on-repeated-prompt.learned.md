---
skill: wk-workflow
date: 2026-07-01
type: gap
severity: medium
---

Before acting on a repeated or re-fired instruction, verify current state instead of blindly re-executing.

**What happened:** An instruction to "continue X, then PR" fired a second time after X was already implemented, reviewed, and merged. The agent started to re-run the pipeline before recognizing the work was already complete.

**Root cause:** A looped/stale prompt is indistinguishable from a fresh one at the text level. No step required checking whether the described work was already done (PR merged, ticket Done) before beginning execution.

**Suggested fix:** Add a pre-execution state check: when a prompt describes work that may already be underway or complete, query current state (open PR? merged? ticket status?) first. If already done, report completion and stop rather than redoing it.
