---
skill: wk-adversarial-review
date: 2026-08-04
type: pattern
severity: medium
verified-against-source: yes
---

Privilege additions should be checked as target-specific contracts.

**What happened:** An allowlist review verified the privileged API call, the generated target
artifact, the unaffected sibling target, and an exact regression assertion together. That exposed
the intended boundary clearly and produced a zero-finding review.

**Root cause:** A privilege name alone does not establish correct scope; the producer, consumer,
and sibling-target outputs together define whether the grant is necessary and narrowly placed.

**Suggested fix:** Preserve the specialized privilege-add sweep and require evidence from the
generated artifact plus a negative assertion for unaffected targets before clearing.
