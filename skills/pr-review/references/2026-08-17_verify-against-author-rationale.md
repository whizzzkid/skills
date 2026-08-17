---
class: principle
skill: wk-pr-review
date: 2026-08-17
---

# Check a figure's derivation before contradicting it

- **Rule:** Before drafting a comment that asserts a number is wrong or proposes
  replacing a constant, read the full comment block at the constant and grep the
  artifact for the derivation rule behind the figure. Refuted, but the derivation
  was unstated and misled an automated reader → reframe as a low-severity clarity
  suggestion rather than dropping the finding silently.
- **Why:** Delegated finding-generation returns only the line a finding anchors to,
  so two classes misfire disproportionately: prose arithmetic, where the derivation
  rule lives in a different section than the figure, and "just retry it" fixes for
  timing constants, where a careful author has often pre-refuted the obvious fix in
  the comment directly above. One reported figure was correct because a rule stated
  two sections away added a step to the total; one proposed poll-and-retry would
  have voided the gate it replaced, because each failed probe wrote the value the
  next probe would read.
- **Where:** Phase 3 — companion HARD RULE to the empirical pass, which covers
  executable logic only and so catches neither class.
- **Reclaimed for budget:** landing this fold required net-negative bytes at a
  ceiling with 15 B headroom. Reclaims taken: a cross-skill duplicate of the
  runtime-matrix rule owned by `wk-adversarial-review`, two restatements of the
  `in_reply_to` 422 fact, a duplicated PR-stack recommendation, a restated outbound
  footer rule, and two of four illustrative label examples.
