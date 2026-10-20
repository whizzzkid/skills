---
skill: wk-pr-review
date: 2026-10-20
type: pattern
severity: medium
verified-against-source: yes
---

Prove DB lock/deadlock claims with a real multi-connection harness, not specs.

**What happened:** A subagent reasoned that a `FOR UPDATE` re-find after a duplicate-key rescue deadlocks with 3+ concurrent losers. Transactional-fixture specs (one connection, one snapshot) cannot show this, and a mutation that dropped the lock stayed green.

**Root cause:** Single-connection test harnesses cannot observe cross-transaction lock interactions.

**Suggested fix:** For concurrency findings, run a script through the framework runner: one winner thread holds an uncommitted insert, N loser threads each `with_connection` + outer transaction, then call the real method. Compare lock variants (e.g. exclusive vs shared). Clean up the rows afterwards.
