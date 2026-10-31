---
skill: wk-adversarial-review
date: 2026-10-30
type: gap
severity: high
verified-against-source: yes
---

A review of a connection-recovery change must check its effect on open transactions, not only that recovery happens.

**What happened:** The fresh adversarial subagent correctly found that recovery raced with connection release and
proposed disconnecting the failed connection at query time. That fix shipped. A review bot then found the new
disconnect also fired mid-transaction, where a framework `disconnect!` resets transaction state and silently discards
work a rescuing savepoint believes is still pending.

**Root cause:** The subagent brief listed connection-pool semantics but never asked how the change, or any fix the
review proposes, behaves while a transaction or savepoint is open on the affected connection.

**Suggested fix:** Add a stance to the subagent brief: for changes that disconnect, reset, or swap connections or
sessions, trace every open-transaction and savepoint state, and apply the same scrutiny to the review's own fix sketches.
