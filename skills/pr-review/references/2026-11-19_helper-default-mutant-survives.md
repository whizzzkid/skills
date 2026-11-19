---
class: principle
source: learnings/skills/pr-review/2026-11-19_helper-default-mutant-survives.learned.md
date: 2026-11-19
severity: medium
skill: wk-pr-review
---

**Rule** — For a matcher or filter that compares field X, confirm the test fixtures set X to the realistic non-zero
value production stamps. A test helper's zero default (empty, nil, 0) lets an equality mutant such as `a.X == b.X`
survive, because zero equals zero. Report the fixture gap, not only a missing assertion. Separately, when a verifier
marks a fail-open finding as a `blocker` but it only triggers on a mistyped config value, re-map it to `suggestion`
under the existing preconditions rule (a mistyped value is non-default config).

**Why** — An "unscoped spec matches any finding" test built its finding with a helper that left the compared field
empty, so the mutant stayed green. In production every finding has that field stamped, so the mutant would make the
unscoped match fail every time, and the test could never catch it.

**Classification** — `partial`. The mutation steps (`wk-adversarial-review` Step 5, `wk-testing-skeleton` Stage 4)
already require killing mutants, and the full-schema fixture rule requires fields to be present, but nothing said a
zero-valued compared field makes an equality mutant survive. The preconditions re-map already covered non-default
config; the edit only makes clear that a mistyped value counts.

**Where** — Fixture check: `wk-adversarial-review` Step 5 (the review-time mutation step this skill delegates to) and
`wk-testing-skeleton` Stage 4 (the shared mutation home). Mistyped-value clause: this skill's Phase 3 preconditions
bullet.
