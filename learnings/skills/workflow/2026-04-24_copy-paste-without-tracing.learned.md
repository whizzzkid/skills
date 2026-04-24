---
skill: wk:workflow
date: 2026-04-24
type: gap
severity: medium
---

Patterns copied from neighbor files without tracing variable provenance produced incorrect behavior.

**What happened:** Adding a label-bypass to bin/guardrail, I copied the
`REVIEW_PR_NUMBER || BUILDKITE_PULL_REQUEST` fallback chain from the
adjacent `bin/checkout_target` script. The user corrected it: in
guardrail's context (target-repo gating, only reachable via external
triggers that always set REVIEW_PR_NUMBER), BUILDKITE_PULL_REQUEST
points at the wrong PR ({repo} itself) and the fallback is
dangerous, not protective.

**Root cause:** wk:workflow does not prescribe a "trace before reuse"
step. The implementation phase is correctly silent on style — but it
also doesn't push the agent to verify that copied semantics still hold
in the new context. Code review (Phase 4) catches the issue eventually,
but only after the bad code is committed, pushed, and embedded in
documentation and tests.

**Suggested fix:** Add a sub-rule under Phase 2 Implementation:

> When reusing a pattern from a neighbor file (env-var fallbacks,
> defaults, conditionals), trace each variable: where is it set, when,
> and does the same code path reach the new location? If the answer
> differs, adapt the pattern; do not copy verbatim. When copying
> across script boundaries (one bin/ script to another), this check
> is mandatory because each script tends to have a different invocation
> environment.
