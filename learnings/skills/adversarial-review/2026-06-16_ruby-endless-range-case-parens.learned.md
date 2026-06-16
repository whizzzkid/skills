---
skill: wk-adversarial-review
date: 2026-06-16
type: surprise
severity: medium
---

Ruby endless range `50..` in a `case/when` must be wrapped `(50..)` or RuboCop raises `Lint/RequireRangeParentheses` and `Lint/EmptyWhen`.

**What happened:** Rewrote a `if/elsif` chain as `case pr_tier / when 50..`. RuboCop parsed `50..` as a range extending to the next expression (`if result...`), triggering `Lint/EmptyWhen` (empty branch) and `Lint/RequireRangeParentheses` (ambiguous range boundary).

**Root cause:** Without parentheses, the Ruby parser sees `50..if_expr` as the range, making the `when` branch appear empty. The fix is `when (50..)`.

**Suggested fix:** When rewriting conditionals with endless or beginless ranges in `case/when`, always wrap them: `when (50..)`, `when (..29)`. Flag bare `50..` or `..29` in `case/when` as a RuboCop-triggering pattern during mechanical sweep 2.15 (workstyle check).
