---
skill: wk-adversarial-review
date: 2026-06-26
type: pattern
severity: medium
---

Read inline design rationale comments to find violations of stated invariants in new code.

**What happened:** A script had an explicit inline comment explaining why a tempfile was promoted to a script-global variable (so the EXIT trap can clean it on SIGINT/SIGTERM). A new function introduced its own local tempfile with the identical race window but did not follow the same global pattern. The adversarial subagent caught this by reading the design comment, understanding the invariant it expressed, then checking whether the new function's tempfile honored it.

**Root cause:** The subagent was instructed to be adversarial and diff-sensitive, but the key was cross-referencing the stated design rationale (in the existing comment) against the new code's divergence from that pattern — a check that grepping for surface bugs alone would miss.

**Suggested fix:** Add to the adversarial subagent prompt: "When a diff introduces a helper or function alongside existing code that has an explanatory design comment (e.g. 'X is global so the trap can clean it'), verify the new code follows the same design invariant — deviations are structural bugs even if the new code compiles and tests pass."
