---
skill: wk-adversarial-review
date: 2026-06-12
type: gap
severity: high
---

Struct field comments drift when a structured return type is added to a different section of the same spec.

**What happened:** A scoring section was updated to require a structured `{decision, reason}` return, but the `Result` struct's `approver_decision` field comment still showed the old flat enum. Two canonical names existed for the same values (e.g., `:comment_loc` in the mechanism section vs `:loc` in the new reason enum). Story implementers would see contradictory shapes.

**Root cause:** The fix was applied at the scoring section (where the requirement was stated) but not at the struct definition (where the stored shape is declared). Cross-field consistency within the same document is not checked by sweeps that focus on cross-file enumeration.

**Suggested fix:** Add a sweep step: after any diff that introduces or changes a structured return type requirement in one section, grep the full document for all field comments that store that return value and verify the shape matches. In a spec doc, this means: find every `Result`/struct field comment referencing the changed type and confirm it uses the new vocabulary.
