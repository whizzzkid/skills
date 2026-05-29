---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

When a PR adds new fields to a public Struct/Result type, mechanical sweeps don't catch a missing direct contract test.

**What happened:** A bot reviewer flagged that newly-added Struct fields had no direct assertions. The existing tests transitively covered field correctness through behavior tests, but would still pass if the fields were dropped or mis-populated by a future refactor. The adversarial-review run pre-push did not surface this; it surfaced only after the bot ran.

**Root cause:** Sweep 2.7 (signature widening) covers function-parameter additions but not Struct/Record field additions. Sweep 2.15 (workstyle) calls out missing tests for "new functions" but Struct field additions look like data not behavior. The mechanical sweep set has no Struct/Record-extension check.

**Suggested fix:** Add a sweep to wk-adversarial-review Step 2: when the diff adds a field to a `Struct.new`, `dataclass`, `class` with `attr_accessor`, named tuple, or equivalent Record type, require a test that asserts the new field carries a concrete expected value (not just `respond_to?`). Detection: grep diff for added field names inside `Struct.new(...)` / `attr_reader :foo` / `field :foo` patterns; cross-grep test files for `expect(<instance>.<field>).to eq(...)` on each new field name.
