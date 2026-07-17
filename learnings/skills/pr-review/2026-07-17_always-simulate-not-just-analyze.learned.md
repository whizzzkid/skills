---
skill: wk-pr-review
date: 2026-07-17
type: gap
severity: high
---

Always run the empirical simulation/playground validation — static analysis is not a substitute, and it demonstrably missed a finding.

**What happened:** Reviewing a spec whose core is a deterministic matcher, I posted findings from lens-based static analysis alone and skipped executing the logic. Only after the user asked "did you try simulating this?" did I drive the real matcher with adversarial inputs — which empirically proved three flake vectors AND surfaced a new finding (a precision cap silently voiding a recall pass) that the static pass never named.

**Root cause:** I substituted reasoning-about-behavior for observing-behavior. The pr-review contract already delegates runtime validation to `wk-adversarial-review`'s playground step, but the arch-review path returned findings and I jumped straight to composing comments, treating the design's logic as "analyzed" without ever running it. Static lenses generate hypotheses; they don't test them, and they miss emergent interactions (e.g. two orthogonal knobs coupling) that only appear when you execute.

**Suggested fix:** When the change under review contains executable logic (a matcher, grader, parser, state machine, algorithm — even in a spec that names a concrete existing implementation), running it is mandatory, not optional. Reuse the real implementation when it exists (drive the actual class/function with crafted inputs) rather than re-deriving it. Build a minimal harness that feeds adversarial/edge inputs and observe PASS/FAIL, before composing findings. Do not let the arch-review path bypass the `wk-adversarial-review` playground/simulation step — a spec review of executable logic still owes an empirical pass. Treat any finding you could have tested but only argued as unverified.
