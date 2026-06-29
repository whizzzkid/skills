---
skill: wk-adversarial-review
date: 2026-06-29
type: gap
severity: medium
---

Adversarial review catches generator-coverage invariants that the second-opinion review tool misses.

**What happened:** A generator updated counts in file A but not file B. The second-opinion local review missed this because no check asks "if automation keeps X in sync in A, does it also keep X in sync in B?" — the diff classifier scoped logic-errors-dataflow to the generator's own directory, so the other consumer was never read.

**Root cause:** The second-opinion check suite operates on the diff and adjacent code; it doesn't reason about cross-file invariants like "this tool claims to be the source of truth for count N — are all consumers of N covered?" This requires intent-aware analysis that no current check performs.

**Suggested fix:** Add to the adversarial subagent's hunting categories: "generator/automation coverage" — when a diff introduces a tool that updates a value in one file, grep for the same value in other files and flag any not updated by the same tool. This class of finding recurs whenever automation is added incrementally.
