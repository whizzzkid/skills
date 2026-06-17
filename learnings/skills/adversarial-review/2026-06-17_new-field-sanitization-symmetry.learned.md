---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: high
---

A new struct field bypassed the sanitization pattern already applied to existing fields of the same type.

**What happened:** When a `Scope string` field was added to a struct that already had a `Model string` field, the new field was initially passed raw to the consumer. A `resolveCheckModel` normalizer already existed for `Model`; no equivalent `resolveCheckScope` was applied at load time. The gap exposed a path traversal vector before adversarial review caught it.

**Root cause:** Sweep 2.7 (signature/contract widening) and sweep 2.19a (struct field assertions) focus on whether callers are updated and whether direct assertions exist. Neither prompts the reviewer to ask: "does this new field need the same normalization/sanitization as an existing field of the same type?" The symmetry check is implicit, not explicit.

**Suggested fix:** Add to Sweep 2.19a (or as a new sweep for struct field additions): when a new field is added to a struct alongside existing fields of the same primitive type, grep for any resolver/normalizer applied to the existing fields and verify the new field receives equivalent treatment. Flag absence of a normalizer as a potential blocker when the field feeds a security-sensitive consumer (file paths, URLs, shell args, allowed-dirs lists).
