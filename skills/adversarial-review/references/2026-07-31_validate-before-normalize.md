---
class: principle
---

# Validate canonical text before numeric conversion

**Rule:** Apply canonical spelling constraints to raw numeric text before converting it to a number. Test aliases
that normalize to the same value.

**Why:** Numeric conversion erases leading zeroes, leading signs, and similar representation differences before a
later date or range check can reject them.

**Where:** `wk-adversarial-review` type-coercion hunting and extended mechanical sweep 2.94.
