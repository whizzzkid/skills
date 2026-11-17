---
skill: wk-workstyle-testing
date: 2026-11-17
type: gap
severity: medium
verified-against-source: yes
---

A thread-race regression test must force the race window open, then be proven red with the fix defeated.

**What happened:** A concurrency spec launched N threads from a start barrier against a check-then-insert path and
asserted zero rejected inserts. It passed even with the serializing fix disabled: interpreter scheduling and the
preceding queries staggered the threads, so they never interleaved inside the narrow check-to-insert window. Only a
negative-control run exposed the test as vacuous.

**Root cause:** A start barrier aligns thread start, not arrival at the critical window; the race only opens if every
thread passes the check before any proceeds.

**Suggested fix:** For check-then-act races, wrap the check step with a bounded rendezvous: each thread waits briefly
(timeout) until all have checked, so without serialization all pass the check first, and with serialization each
wait simply expires (keep N × timeout under any lock wait). Always run the spec once with the fix defeated and require
red before trusting green. When mutating for that control, prefer a mutation that changes behaviour unambiguously
(e.g. a per-session lock name), not a boolean trick whose truthiness the language may not honour.
