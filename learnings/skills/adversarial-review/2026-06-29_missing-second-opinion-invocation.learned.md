---
skill: wk-adversarial-review
date: 2026-06-29
type: correction
severity: high
---

Agent missed mandatory second-opinion review-tool invocation during the adversarial review gate.

**What happened:** The adversarial review was running (mechanical sweeps + subagent), but the agent did not invoke the configured second-opinion review tool as required by a private HARD RULE (invoke it in the same turn as `wk-adversarial-review`). User had to ask whether the local second-opinion review was running.

**Root cause:** The binding rule lives in private global instructions; the public `wk-adversarial-review` skill carried only preamble bullets ("Detect a configured second-opinion review integration (review binary on PATH / env flag) and invoke it this same turn"). The binary was present on PATH — the trigger should have fired. It was treated as ambient prose rather than a numbered sweep step.

**Suggested fix:** Convert the preamble bullets into an unconditional sweep-catalog row that probes for the tool (`command -v <tool>` / env flag) and invokes it before subagent dispatch. The preamble wording was insufficiently imperative and lost to context pressure.
