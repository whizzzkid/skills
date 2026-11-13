---
skill: wk-pr-review
date: 2026-11-13
type: pattern
severity: medium
verified-against-source: n/a
---

Adversarial subagent "blockers" often hinge on non-default config or unpinned external behavior; re-map before the approve gate.

**What happened:** The subagent raised two blockers. One was a git-ignore guard that only fails with an unusual ignore pattern while the default rule covers it. The other was a "labelled row" detector that misses reviewer notes only if the external review tool is configured to write them to a custom metadata path. Both were real, but neither was critical under the shipped defaults.

**Root cause:** The verifier prompt included the severity definitions, but the agent still rated any reachable data-loss path as blocker, whatever preconditions it needed.

**Suggested fix:** In Phase 3, ask the verifier to state the preconditions for each blocker (default config vs custom config vs unpinned external behavior). A finding that needs non-default config becomes a suggestion; one that needs unpinned external behavior becomes a question.
