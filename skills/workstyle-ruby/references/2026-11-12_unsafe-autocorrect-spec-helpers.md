---
class: principle
skill: wk-workstyle-ruby
date: 2026-11-12
severity: low
---

**Rule** — Write RSpec helpers as `let` lambdas or support-module methods, never `def` inside an
example group; treat any `rubocop -A` run as an unverified edit and re-run RuboCop plus the
affected specs afterwards.

**Why** — A cop banning `def` in blocks autocorrected helpers to `define_method`; a second cop
banning metaprogramming flagged the result, and the rewrite of an endless one-line `def` produced
a syntax error that broke the whole file. Unsafe autocorrects are independent rewrites with no
cross-cop consistency or syntax guarantee. Generalizes the existing block-forwarding bullet,
where an autocorrect likewise broke a sibling constraint.

**Where** — `wk-workstyle-ruby` → Sorbet strict-mode friction (spec-helper form); Verify with
RuboCop (re-verify after `-A`).
