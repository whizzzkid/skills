---
class: principle
date: 2026-05-21
severity: medium
---

- **Rule:** When coercing one argument or field, audit every sibling argument of the same semantic class (role + nullability + type shape) in the same pass.
- **Why:** Fixing only the visible case leaves same-class siblings carrying the original bug; adversarial review catches it pre-push only on the lucky pass.
- **Where:** Phase 2 Implement — new "Same-semantic-class audit on coercions" HARD RULE before "Code Standards".
