---
skill: wk-adversarial-review
date: 2026-06-18
type: pattern
severity: medium
---

Per-field fail-open validation is safer than all-or-nothing record drop for partial-override structures.

**What happened:** A validation helper rejected an entire classification record when any single field was invalid (wrong model name, bad effort level). The reviewer surfaced that this dropped valid overrides for the other fields — a single bad model value would discard a correctly-specified effort and scope. The fix replaced the all-or-nothing helper with a per-field sanitization loop: each field is validated independently; invalid fields are zeroed and logged, valid fields are kept; the record is only dropped when all fields are invalid.

**Root cause:** All-or-nothing validation is the wrong contract for partial-override structures (where empty string means "keep existing value"). A single invalid field signals a model hallucination for that field, not a corrupt record — discarding the whole record forfeits correct overrides.

**Suggested fix:** When reviewing validation logic for structures that carry independent optional overrides, check whether the failure mode is per-field (one bad value) or per-record (structurally malformed). Per-field failures should drop only the offending field (fail-open); only structurally malformed records warrant dropping the whole entry. Flag all-or-nothing validators on partial-override structs as candidates for this refactor.
