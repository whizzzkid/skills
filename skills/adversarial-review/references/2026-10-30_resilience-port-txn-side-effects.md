---
class: principle
skill: wk-adversarial-review
date: 2026-10-30
severity: high
---

**Rule** — When a diff, or a fix sketch the review itself proposes, disconnects, resets, reconnects, or swaps a
connection or session, brief the subagent to trace every open-transaction and savepoint state on that connection and
who owns the connection at that moment. Reviewing only that recovery happens is not enough.

**Why** — A review correctly found that a ported recovery mechanism raced with connection release and proposed
disconnecting the failed connection at query time. The fix shipped, and the new disconnect also fired mid-transaction.
A framework disconnect resets transaction state (verified in the upstream adapter source: `disconnect!` calls
`reset_transaction`), so work a rescuing savepoint believed pending was silently discarded. The brief covered pool
semantics but never asked about open transactions, and the review's own fix sketch got no scrutiny.

**Where** — `SKILL.md` → Step 3 (Fresh Adversarial Subagent), and the transaction-state-aware stance in
`references/subagent-stances.md`.
