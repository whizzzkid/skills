---
class: principle
skill: wk-workflow
date: 2026-06-16
severity: high
---

**Rule:** Never add a `skip_*`/`bypass_*`/`force_*` parameter that disables an
existing feature gate, guardrail, or rate limit without explicit user
confirmation. When a gate genuinely cannot be honored (its input is unavailable
at call time), document it as a known limitation — do not silently remove the
protection.

**Why:** A new code path tempts the agent to rationalize a gate as an
"unavoidable" obstacle and bypass it. Silently dropping a security or
rate-limiting gate weakens the system's invariants; the user owns that
trade-off, not the agent.

**Where:** Phase 2 → Code Standards → "Existing-gate preservation".
