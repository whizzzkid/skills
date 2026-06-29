---
class: principle
---

**Rule**

When a sharpen edit changes the size of any enumerated set the sibling README
quotes a count of (e.g. "Run N sweeps"), recount the count from the
authoritative source files and overwrite the literal — never increment the
displayed number.

**Why**

A free-standing numeric count is a generator-coverage consumer: it silently
drifts whenever rows are added by any prior session. A naive "+N" bump
inherits the existing stale value and stays wrong. Recounting from source is
the only way to get a correct total.

**Where**

Step 7 README Drift check.
