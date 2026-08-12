---
class: one-off
date: 2026-08-11
skill: wk-adversarial-review
---

# Abstract-class refactor breaks shared test helpers

- **Scenario:** A stacked PR's base branches independently refactored a class into
  an abstract parent. The child PR's test helpers still called `AbstractClass.new(...)`,
  rejected at runtime by Sorbet's `abstract!` with a misleading argument error.
- **Symptom:** `wrong number of arguments (given 1, expected 0)` from Sorbet internals
  instead of a clear "cannot instantiate abstract class" message. Only surfaces at
  runtime; `srb tc` in `typed: false` test files does not flag it.
- **Fix:** After any rebase/merge touching a class hierarchy, grep test support files
  for direct `.new` calls on classes that now declare `abstract!` or equivalent:
  `grep -rn 'ClassName\.new' spec/support/ spec/factories/`.
- **Why not promoted:** Sweep 2.44 covers merge-conflict call-site resolution. This
  is a Sorbet-specific rare-configuration failure (abstract refactor + stacked PRs).
  Body at ceiling (9 B headroom).
