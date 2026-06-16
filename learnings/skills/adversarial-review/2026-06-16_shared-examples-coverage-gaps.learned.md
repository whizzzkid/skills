---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: medium
---

When reviewing test deduplication via `shared_examples` (or equivalent parameterized test factories), audit three coverage gaps the deduplication itself may introduce.

**What happened:** A test refactor extracted 6 shared gate contexts into a `shared_examples` block parameterized by method name and extra kwargs. The adversarial pass correctly flagged three gaps the deduplicated tests did not cover: (1) the per-caller `label:` kwarg behavior (log-prefix variants in warnings were untested), (2) bin-level end-to-end APPROVE/COMMENT posting for the new public method — unit tests deduplication doesn't substitute for bin wiring tests, (3) the SHA env-var fallback path in the bin wrapper.

**Root cause:** Shared examples test the shared logic correctly but can obscure caller-specific behavior (different log labels, different calling conventions in higher-level bin scripts) that existed in the per-method test blocks being replaced.

**Suggested fix:** Add three questions to the "test quality" sweep when a diff converts per-method test contexts into a shared_examples/parameterized block: (a) does any parameter control log output or warn messages that are not asserted in the shared block? (b) does any target method have a higher-level integration test (bin-level, controller-level) that exercises the full calling chain? (c) are there env-var fallbacks in the caller that only exercise when the method is invoked through the real entry point, not via public_send?
