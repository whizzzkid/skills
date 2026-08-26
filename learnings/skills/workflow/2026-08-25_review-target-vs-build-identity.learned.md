---
skill: wk-workflow
date: 2026-08-25
type: correction
severity: high
verified-against-source: yes
---

Distinguish the review target's identity from the build's own identity when composing keys

**What happened:** When adding a `stable-selection-key` parameter to a CI plugin,
the agent found existing helpers that resolve repo slugs and PR numbers — including
fallback chains from target-review env vars to build-own env vars. The agent reused
the full fallback chain (target + build-own) for the key, despite the key's purpose
being to identify the *target under review*, not the build itself. The user corrected
this twice: first pointing out the semantics, then pointing out that the agent had
already found the existing code showing the distinction and ignored it.

**Root cause:** The agent treated env-var fallback chains as interchangeable
data sources rather than understanding their semantic domains. In this CI system,
`REVIEW_*` vars identify the external target being reviewed (set by the
orchestrator), while `BUILDKITE_*` vars identify the pipeline build itself.
Helpers like `pr_number_with_buildkite_fallback` exist for "is any PR present?"
gating, not for "which PR is being reviewed?" identity. The agent found and read
these helpers but conflated the two questions.

**Suggested fix:** When composing an identifier or key from env vars, first
classify each candidate var by semantic domain (target vs. self, external vs.
internal). A fallback chain that crosses domains is a gate/presence check, not
an identity source. Re-read the existing code's comments and helper names for
domain signals before reusing them in a new context.
