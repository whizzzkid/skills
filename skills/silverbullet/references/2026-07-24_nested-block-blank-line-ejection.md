---
class: principle
---

# Blank lines around a nested element eject it from its parent

**Rule:** Treat a container's entire body as one contiguous run of lines. Never pad a
nested `<div>`/`<pre>` with a blank line before or after it, at any nesting depth.

**Why:** CommonMark type-6 HTML blocks end at the first blank line. The rule is
routinely read as "don't pad the outermost container" — but a blank line around an
*inner* element closes the *outer* block just the same. The child then renders
full-width below the layout while the parent still holds its remaining content, so
any parent-level "is it non-empty" check still passes and the break goes unnoticed.

**Where:** §Critical Constraints → HTML blocks — no blank lines inside; Common
Mistakes; Quick Reference. Escalated from a repeat violation of the existing HARD
RULE: the scope clause ("nesting depth is irrelevant") now carries the load, since
the un-scoped wording had already failed once in the field.
