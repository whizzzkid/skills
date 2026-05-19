---
skill: wk-adversarial-review
date: 2026-05-19
type: gap
severity: high
---

Sort-order test that compares array to its own .sort is always true.

**What happened:** A restored spec compared `[a, b, c, d]` to
`[a, b, c, d].sort` — both sides are derived from the same variables,
so the assertion is always equal regardless of actual order. The test
passed even if the sort were inverted.

**Root cause:** Sweep 2.15 (workstyle) and the adversarial subagent
should catch tautological assertions, but the specific pattern of
self-sort comparison wasn't on the checklist.

**Suggested fix:** Add to sweep 2.15: grep new spec/test files for
`.sort)` appearing in an `eq(...)` call where both sides reference the
same variables. Also flag any `expect(x).to eq(x)` form. Detection:
`grep -nE 'eq\(.*\.sort\)' spec/ test/`.

**Confidence:** high
