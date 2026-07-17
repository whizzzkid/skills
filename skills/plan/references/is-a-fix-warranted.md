---
class: principle
---

**Rule:** When an investigation's root cause is benign (correct behavior, external
timing, no defect), surface "no fix needed / close as working-as-intended" as an
explicit `[HUMAN-IN-LOOP]` option and confirm the user wants a change before
planning one.

**Why:** The Step 0 grill treats the task as a fix to be scoped and skips the prior
question of whether a fix is warranted at all. Defaulting to a fix because a ticket
exists produces unwanted code changes for a false alarm.

**Where:** Step 0, alongside the fix-philosophy branch.
