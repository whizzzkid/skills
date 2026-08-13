---
skill: wk-workflow
date: 2026-08-12
type: correction
severity: medium
verified-against-source: n/a
---

Evaluate subtractive/exclusion-based fixes before building additive CI machinery.

**What happened:** Agent built 3 successive PRs of increasing complexity (new CLI subcommand, GitHub Contents API commit-signing workaround, workflow gate-splitting logic) to fix a recurring CI failure, before the user prompted a rethink that revealed the simplest fix was excluding one file from a hash-check's input set. The exclusion was a net -39 line diff with zero new failure modes.

**Root cause:** (unverified — inferred from symptom) The workflow skill's implementation phase does not prompt the agent to evaluate removal/exclusion approaches before additive ones. The agent's default mode is to solve forward (add code to handle the problem) rather than backward (remove the condition that creates the problem).

**Suggested fix:** Add a pre-implementation checkpoint to Phase 2: before building new commands, workflow steps, or workarounds, ask "Can I make this problem not exist by excluding, removing, or simplifying something?" Document this as a first-pass heuristic in the skill's implementation guidance.
