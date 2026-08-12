---
class: one-off
date: 2026-08-11
skill: wk-pr-resolve
---

# Sorbet requires_ancestor alone does not resolve methods in mixin body

- **Scenario:** A `prepend`-based module with `requires_ancestor { AncestorClass }`
  called `reject` (from the ancestor); `srb tc` reported `Method 'reject' does not
  exist on ModuleName`.
- **Symptom:** `requires_ancestor` constrains the mixin site but does not make
  Sorbet treat the method body as having the ancestor's type.
- **Fix:** Pair `requires_ancestor` with `T.bind(self, AncestorClass)` as the first
  line of any method that calls inherited instance methods. Both are needed:
  `requires_ancestor` for the contract, `T.bind` for the body's type context.
- **Why not promoted:** Sorbet-specific typing pattern in `prepend`-based modules;
  narrow enough that a general rule would overfit.
