---
skill: wk-pr-resolve
date: 2026-05-29
type: correction
severity: high
---

Read and implement RUN_LOCALLY.md contents before deleting it

**What happened:** When adopting a cloud-agent PR that contained a RUN_LOCALLY.md handoff file, the agent began deleting the file as cleanup without first reading it and implementing the remaining work it described.

**Root cause:** The wk-pr-resolve "adopt and resolve" flow focuses on merge conflicts and review comments; it has no explicit step to detect and action handoff documents (RUN_LOCALLY.md, NEXT_PHASE.md, HANDOFF.md) present in the branch before cleaning up.

**Suggested fix:** Before deleting any handoff doc (RUN_LOCALLY.md, NEXT_PHASE.md, or any file whose name suggests remaining work), read the file fully and implement every item it describes. Only then delete it — in the same commit as the last implementation change, not as a standalone cleanup. If the remaining work spans multiple repos or is large in scope, present a plan to the user before proceeding.
