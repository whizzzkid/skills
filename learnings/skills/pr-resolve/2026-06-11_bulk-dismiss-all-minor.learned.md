---
skill: wk-pr-resolve
date: 2026-06-11
type: gap
severity: medium
---

When all active bot findings are Minor severity, offer a single bulk-dismiss option before entering the per-item consultation loop.

**What happened:** Three bot findings were all Minor severity. The skill presented each one-at-a-time per its normal flow (1 obvious-fix queued, 2 judgment-required consulted). After both judgment-required items were dismissed and the agent began implementing the obvious-fix, the user interrupted to dismiss all three and merge.

**Root cause:** The skill has no fast-path for "all findings are Minor" — it always enters the full per-item loop regardless of severity. The user's preference was to dismiss all Minor findings without ceremony, but the protocol forced a full triage pass.

**Suggested fix:** At the start of Step 4/5, when every active finding carries Minor severity and each has a plausible skip rationale, add a pre-triage gate: "All {N} findings are Minor. Bulk dismiss all? (y to dismiss all / n to triage individually)." Accept 'y' as a bulk-dismiss, post dismissal replies, resolve all threads, and skip the per-item loop entirely. Only enter per-item consultation when at least one finding is Major/Critical or carries an empty skip rationale.
