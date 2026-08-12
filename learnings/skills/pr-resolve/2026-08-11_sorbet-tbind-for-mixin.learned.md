---
skill: wk-pr-resolve
date: 2026-08-11
type: surprise
severity: medium
verified-against-source: yes
---

Sorbet `requires_ancestor` alone does not resolve inherited methods inside a mixin body — `T.bind` is also needed

**What happened:** A `prepend`-based module defined a method calling `reject`
(inherited from the ancestor class). Adding `requires_ancestor { AncestorClass }`
satisfied the mixin-site contract but `bundle exec srb tc` still reported
`Method 'reject' does not exist on ModuleName`.

**Root cause:** `requires_ancestor` constrains where the module can be mixed in but
does not make Sorbet treat the method body as having the ancestor's type. Adding
`T.bind(self, AncestorClass)` as the first line of the method body is required so
Sorbet resolves the ancestor's instance methods within that body. Both are needed:
`requires_ancestor` for the contract, `T.bind` for the body's type context.
Confirmed by `bundle exec srb tc` passing only after adding `T.bind`.

**Suggested fix:** When writing `prepend`-based mixin modules in Sorbet-typed repos,
always pair `requires_ancestor` with `T.bind(self, AncestorClass)` inside any method
that calls inherited instance methods. Add this as a note in the skill's Sorbet
guidance section.
