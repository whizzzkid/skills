---
name: unverified-test-claim-audit
description: Spec prose claiming "tests verify X" must map to an actual test function.
class: principle
---

- **Rule:** Grep spec docs for "tests verify / a test confirms /
  unit tests assert / spec asserts" claims. For each hit, locate
  the relevant test file and confirm a function or `it`/`test`
  description matches the claimed behavior. Flag unverified
  claims as blockers.
- **Why:** Authors sometimes write the spec as if the test exists
  before adding it (or never adding it). The spec then asserts
  coverage that no test enforces — a silent gap that ships.
- **Where:** Sweep 2.8 (Cross-doc enumeration sync),
  "Unverified test-claim audit" block before universality-claim
  verification.
