---
class: principle
---

**Rule**

When a new parameterized integration test iterates a helper's nil/error paths,
grep the helper's unit spec. If the unit suite already asserts all the iterated
cases return the same value, keep one representative case at the integration
boundary and drop the rest. Sweep 2.42.

**Why**

Iterating every nil-source through the integration path re-tests the helper's
internals rather than the integration contract. The boundary only needs one
case to verify routing.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.42.
