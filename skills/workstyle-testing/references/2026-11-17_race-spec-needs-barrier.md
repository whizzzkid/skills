---
class: principle
---

- **Rule** — A thread-race regression test must force the race window open and be proven red with the fix defeated.
  For check-then-act races, wrap the check step in a bounded rendezvous: each thread waits (with timeout) until all
  have checked, so without serialization all pass the check first, and with serialization each wait simply expires
  (keep N × timeout under any lock wait). Defeat the fix with a mutation that changes behavior unambiguously, not a
  boolean trick whose truthiness the language may not honor.
- **Why** — A spec launched N threads from a start barrier against a check-then-insert path and asserted zero rejected
  inserts. It passed with the serializing fix disabled: scheduling and preceding queries staggered the threads, so they
  never interleaved inside the narrow check-to-insert window. Only a negative-control run exposed it as vacuous.
- **Where** — `SKILL.md` Rules: "A regression test is trusted green only after it ran red" and "Race specs force the
  window open".
