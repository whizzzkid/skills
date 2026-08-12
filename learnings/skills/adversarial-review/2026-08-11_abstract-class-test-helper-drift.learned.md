---
skill: wk-adversarial-review
date: 2026-08-11
type: gap
severity: medium
verified-against-source: yes
---

Shared test helpers that instantiate a class directly break silently when
that class becomes abstract in a refactor merged through a parallel branch.

**What happened:** A stacked PR's base branches merged independently, each
refactoring a configuration class into an abstract parent with concrete
subclasses. The child PR's test helpers still called `AbstractClass.new(...)`,
which Sorbet's `abstract!` declaration rejects at runtime with
`wrong number of arguments (given 1, expected 0)` — a misleading error that
doesn't name the abstract constraint.

**Root cause:** When a class gains `abstract!` (or equivalent in other
frameworks), every direct `.new` call becomes invalid, but static analysis
(Sorbet `srb tc`) does not flag it in `typed: false` test files. The failure
only surfaces at runtime, and the error message points to the Sorbet internals
rather than the abstract declaration.

**Suggested fix:** After any rebase/merge that touches a class hierarchy,
grep test support files for direct instantiation of the refactored class:
`grep -rn 'ClassName\.new' spec/support/ spec/factories/`. Flag any hit on a
class that now declares `abstract!` or its language equivalent. This is a
mechanical scan the adversarial-review or pr-update skill could automate as a
post-conflict-resolution check.
