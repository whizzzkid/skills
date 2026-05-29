---
class: principle
skill: wk-refactor
date: 2026-05-29
---

# Stale literal after constant → resolver swap

- **Rule:** When a refactor replaces a named constant with a resolver/function,
  grep the constant's old *literal value* (not just its identifier) across
  scope; non-comment/non-fixture hits must use the resolver's return value.
- **Why:** Identifier-grep finds symbol references but misses hardcoded copies
  of the value in format strings / error messages / logs — those are unchanged
  lines the removed-line audit never inspects, so a stale literal ships.
- **Where:** Stage 2 removed-line audit → "Stale-literal check
  (constant → resolver / value-bearing rename)".
