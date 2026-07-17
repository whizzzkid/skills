---
class: principle
---

# Env-var delivery path through a sandboxed step

**Rule** — A new env var consumed inside a containerized/sandboxed step (docker-compose
service, CI runner job) is not delivered until the step's passthrough `env:` allowlist
carries it. Adding the reader alone ships dead code. In the same change, trace the full
path: producer (agent/secret) → container/runner env allowlist → reader; mirror how a
sibling secret in the same step is forwarded. Confirm delivery in a real run (build log),
not env-stubbing unit tests.

**Why** — Verification that stops at "code reads the var" and "value is set" skips the
delivery path in between. Containerized steps only receive vars explicitly listed in the
runner's allowlist; env-stubbing unit tests stub the read and pass green even when the var
never reaches the process, so the feature is dead-on-arrival with no failing signal.

**Where** — `wk-workflow` SKILL.md, Phase 2 "Edit-scope pre-flights" (env-var-in-a-sandboxed-step
bullet). Reinforces Phase 3's real-run verification over stub-only tests.
