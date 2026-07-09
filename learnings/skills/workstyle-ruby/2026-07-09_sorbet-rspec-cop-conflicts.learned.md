---
skill: wk-workstyle-ruby
date: 2026-07-09
type: gap
severity: medium
---

Sorbet + RuboCop cop conflicts recur on controller specs, auth modules, and literal-space regexes.

**What happened:** Three separate cop/type-check conflicts surfaced while adding a bearer-auth base controller and its spec: an anonymous RSpec `controller do ... end` block tripped `Sorbet/BlockMethodDefinition` against the no-metaprogramming cop; an `ActiveSupport::Concern` auth module failed under Sorbet `requires_ancestor` + `included do`; and a regex with a literal `[ ]` single-space class was rejected by `Style/RedundantRegexpCharacterClass`.

**Root cause:** The skill lacks guidance on the friction points between Sorbet strict typing and RuboCop/$EMPLOYER cops for common Rails testing and metaprogramming idioms.

**Suggested fix:** Add Ruby workstyle guidance: (1) exercise a shared base-controller `before_action` via a concrete named subclass in the spec, not an anonymous `controller do` block; (2) prefer a plain sig'd class with an inlined filter over an `ActiveSupport::Concern` when the app has no concern precedent and `requires_ancestor` + `included do` fails Sorbet; (3) write a required literal single space in a regex as `\x20` — never a bare space (invisible) and never `[ ]` (redundant character class).
