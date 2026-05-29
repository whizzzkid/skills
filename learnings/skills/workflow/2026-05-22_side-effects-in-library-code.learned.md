---
skill: wk-workflow
date: 2026-05-22
type: correction
severity: medium
---

Agent introduced duplicate ENV read and stdout side effects inside a library module.

**What happened:** Agent added a `Rollout.cutoff` read + `puts` log block to both `bin/guardrail` and `GuardrailDecision.first_block_reason`, duplicating the env parse and adding stdout side effects to what should be pure decision logic. User caught it: "why are we duplicating checks?"

**Root cause:** Agent added the logging where it was easiest (top of decide) rather than thinking about layer responsibility. Library/model layer should have no stdout; the script/view layer owns rendering.

**Suggested fix:** Before adding `puts` or ENV reads to a module, check whether the module's responsibility is decision-returning (pure) vs side-effecting. Side effects belong at the entrypoint script layer, not library code. Surface data via return values.
