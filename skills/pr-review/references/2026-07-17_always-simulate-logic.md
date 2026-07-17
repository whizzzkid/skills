---
class: principle
---

**Rule:** When the change under review contains executable logic (matcher, grader,
parser, state machine, algorithm — even a spec naming a concrete implementation),
running it is mandatory. Drive the real implementation or a minimal harness with
adversarial/edge inputs and record PASS/FAIL before composing comments —
including findings returned from the Phase 1 `wk-arch-review` path. Treat a finding
you could have executed but only argued as unverified.

**Why:** Reasoning-about-behavior substituted for observing-behavior demonstrably
missed a finding (a precision cap silently voiding a recall pass) that only surfaced
on execution; the arch-review path returned findings that bypassed the
`wk-adversarial-review` playground step.

**Where:** wk-pr-review Phase 3 — new HARD RULE "logic-bearing findings need an
empirical pass."
