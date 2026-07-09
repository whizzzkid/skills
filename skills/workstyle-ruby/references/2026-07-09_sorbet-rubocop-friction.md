---
skill: wk-workstyle-ruby
class: principle
---

**Rule** — Under Sorbet strict typing plus RuboCop, three Rails idioms recur as
conflicts: (1) a required literal single space in a regex is `\x20`, never a
bare space or `[ ]`; (2) exercise a shared base-controller filter via a concrete
named subclass in the spec, not an anonymous `controller do … end` block; (3)
prefer a plain sig'd class with an inlined filter over `ActiveSupport::Concern`
when the app has no concern precedent.

**Why** — `[ ]` trips `Style/RedundantRegexpCharacterClass` and a bare space is
invisible; an anonymous `controller do` block trips
`Sorbet/BlockMethodDefinition` against the no-metaprogramming cop;
`ActiveSupport::Concern` with Sorbet `requires_ancestor` + `included do` fails to
type-check. Each is a plausible default that fails the cop/type-check gate.

**Where** — wk-workstyle-ruby Rules and the Sorbet strict-mode friction section.
