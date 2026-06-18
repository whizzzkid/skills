---
class: principle
---

**Rule:** Flag a `-> {` lambda that spans multiple lines OR contains a `rescue` clause AND sits inside an array literal — the brace form is a parse error there; require `-> do ... end`.

**Why:** In array position, Ruby's parser treats `{` as ambiguous with a block delimiter and fails before reaching `rescue`. RuboCop `Style/BlockDelimiters` also enforces `do...end` on multi-line procs/lambdas.

**Where:** Sweep 2.39 (extended alongside `Style/AsciiComments`).
