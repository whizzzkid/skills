---
skill: wk-adversarial-review
date: 2026-07-10
type: pattern
severity: medium
---

An "accepts every valid enum value" test built with `build(...).valid?` is tautological when the enum's valid set is *derived from* the same constant the test iterates.

**What happened:** A bot flagged undertested enums. The fix added specs looping over `MODEL::CONST` asserting each value builds valid. But the model defines the enum as `enum :x, CONST.index_by(&:itself)` — so the accepted set is CONST by construction. The loop can never fail; it also can't catch a dropped `validate:` flag (only the pre-existing invalid-value negative case does).

**Root cause:** Iterating the same constant that defines the enum is self-referential. `build`-only assertions never reach the DB, so any DB CHECK-constraint drift also goes untested.

**Suggested fix:** For enum-parity coverage, adversarial review should require (a) `create`/persist so DB CHECK constraints are exercised, and (b) an independent exact-match assertion `expect(Model.xs.keys).to match_array(Model::CONST)` guarding against undocumented enum drift — not a loop over the defining constant.
