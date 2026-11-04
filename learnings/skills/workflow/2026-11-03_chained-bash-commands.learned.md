---
skill: wk-workflow
date: 2026-11-03
type: correction
severity: low
verified-against-source: n/a
---

Commands were repeatedly chained with `&&` in a single shell call despite the one-command-per-call rule.

**What happened:** Across a long session the agent combined staging, committing and pushing into one call, and paired
a file edit with a verification grep in another. The rule says dependent commands go in separate sequential calls and
independent ones in parallel calls. It was never flagged live, so it repeated.

**Root cause:** The commit and push steps read as one logical action, and the chain looked harmless because each
command was individually safe. Nothing in the flow forces a stop between them, so the habit stuck.

**Suggested fix:** Add a short pre-call check to the Phase 2 code standards: a shell call containing `&&`, `||` or `;`
between commands is split before sending, except where one of the commands is the deliberate gate for the next.
