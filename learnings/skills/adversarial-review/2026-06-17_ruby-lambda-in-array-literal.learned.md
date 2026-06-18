---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: medium
---

Ruby `-> { rescue }` inside an array literal is a parse error; multi-line lambdas in array position require `do...end`.

**What happened:** A refactor placed a multi-line lambda with a `rescue` clause inside an array literal using `-> { ... rescue ... }`. Ruby's parser rejects bare `rescue` inside a brace block when the lambda is in array position — the `{` is ambiguous with a block delimiter and the parser fails before reaching `rescue`.

**Root cause:** Sweep 2.15 and the Ruby cop catalog cover `Style/BlockDelimiters` for method calls but do not flag the specific case of a multi-line lambda with rescue in array position, where `-> { }` must become `-> do...end`.

**Suggested fix:** Add to the Ruby sweep catalog: when a diff introduces a `-> {` lambda that spans multiple lines OR contains a `rescue` clause AND appears inside an array literal (`[..., -> { ... }, ...]`), flag it as a blocker — the brace form is a parse error in that context; `-> do...end` is required. RuboCop `Style/BlockDelimiters` also enforces this on multi-line procs/lambdas.
