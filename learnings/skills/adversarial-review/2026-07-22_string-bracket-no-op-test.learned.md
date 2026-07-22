---
skill: wk-adversarial-review
date: 2026-07-22
type: gap
severity: medium
---

A regression test meant to pin a type-guard (`unless attrs.is_a?(Hash)`) included a `String` element as one of its "invalid shape" fixtures. `String#[]` with a string key is a silent substring lookup returning `nil`, not a raise — so that fixture passed identically whether the guard existed or not, contributing zero coverage while looking like coverage.

**What happened:** A fix added a `is_a?(Hash)` guard against non-Hash elements in an array (values from parsed JSON: could be `nil`, string, integer, array, etc.). The accompanying test used `nil` and a string literal as the "bad" elements. Only the `nil` case actually exercised the guard; the string case silently passed either way because `String#[](key)` doesn't raise for a non-integer/non-regex key the way `NilClass#[]` or `Integer#[]` do.

**Root cause:** Ruby's `#[]` has wildly different semantics per receiver type (Hash: key lookup and raises on wrong arity elsewhere; String: substring/pattern match, returns nil on no match; Array: index access; NilClass: undefined method). A reviewer assuming "any non-Hash element will raise on `#[]`" is wrong — only some non-Hash types do. Multi-type guard tests need at least one fixture per behaviorally-distinct type, not just "a couple of different-looking values."

**Suggested fix:** When reviewing a test that exercises a type guard against "any element that isn't type X," explicitly enumerate Ruby's other common types the guard must reject (`nil`, `String`, `Integer`, `Array`, `TrueClass/FalseClass`) and mentally run each through the exact method call inside the guarded path — not just check that the guard's own type-check would return false. A single `String` fixture is not equivalent to "any non-Hash." This generalizes to any dynamically-typed language guard test: verify each fixture forces execution into the guarded branch, not just that it satisfies the guard's own predicate.
