---
class: principle
skill: wk-workstyle-ruby
date: 2026-06-16
---

**Rule:** Parenthesize endless/beginless ranges in `case/when`: `when (50..)`,
`when (..29)` — never bare `when 50..`.

**Why:** Without parens the Ruby parser reads `50..` as a range extending into
the next expression, making the `when` branch appear empty. RuboCop then raises
`Lint/RequireRangeParentheses` and `Lint/EmptyWhen`, breaking CI.

**Where:** Rules section (enumerable/control-flow idioms).
