---
class: principle
skill: wk-adversarial-review
date: 2026-06-18
---

**Rule:** When reviewing validation on a struct that carries independent optional
overrides (empty value means "keep existing"), reject all-or-nothing validators.
A single invalid field is a per-field hallucination, not a corrupt record —
validate each field independently, zero+log the invalid ones (fail-open), keep
the valid ones, and drop the whole record only when every field is invalid.

**Why:** All-or-nothing drop forfeits correct overrides: one bad model name
discards a correctly-specified effort and scope. The failure mode is per-field,
so the remedy must be per-field; per-record drop is the wrong contract for
partial-override structures.

**Where:** Step 2 sweep catalog — validation-contract row. Applies to any
sanitizer over a partial-override / optional-field struct.
