---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: medium
---

New struct field with .to_s serialization untested for the nil/zero-value path

**What happened:** A new tag field was wired as `field.to_s` in a metrics emitter. Specs
covered all non-nil values (APPROVE, COMMENT) but not the nil case, which serializes to "".
The nil path is the most common production path (silent skips, error rescues) and a
NoMethodError regression there would not have been caught.

**Root cause:** Sweep 2.19a checks for direct assertions on new struct fields but focuses
on the non-nil "happy path" values. The nil/zero-value path through `.to_s` (a
serialization boundary) falls outside the existing trigger description.

**Suggested fix:** Add a sub-check to 2.19a: when a new struct field is serialized via
`.to_s` or similar, verify the test set includes a case where that field is nil/false/0.
A missing nil-path test on a serialization boundary is a medium-severity gap, not a
cosmetic omission.
