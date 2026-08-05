---
class: principle
---

# Sweep every runtime harness after a contract change

**Rule:** Sweep the whole repository for stubs, injected globals, and harness implementations after a cross-system
signature change. Drive one real consumer per distinct harness.

**Why:** Colocated fakes and type checks can pass while a separately installed runtime global still implements the old
contract.

**Where:** Mechanical sweep 2.7 for signature and contract widening.
