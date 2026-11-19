---
skill: wk-pr-review
date: 2026-11-19
type: pattern
severity: medium
verified-against-source: yes
---

A test helper's zero-value default can hide a surviving mutant in a field-comparing matcher.

**What happened:** A matcher's "unscoped spec matches any finding" test built its finding with a helper that left the
compared field empty. The mutant `return spec.X == f.X` stayed green because empty equals empty. In production, every
finding has that field stamped, so the mutant would turn the assertion into one that can never fail.

**Root cause:** The skill's mutation step doesn't tell the reviewer to check whether test fixtures populate the fields
the logic under test compares.

**Suggested fix:** In Phase 3 mutation guidance, for a matcher or filter that compares field X, check that the test
fixtures set X to a realistic non-zero value. A zero default makes equality mutants survive. Also, when an adversarial
verifier marks a fail-open finding as a blocker but it needs a mistyped config value to trigger, re-map it to
`suggestion` under the existing preconditions rule.
