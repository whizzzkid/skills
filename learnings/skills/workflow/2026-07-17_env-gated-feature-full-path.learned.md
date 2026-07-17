---
skill: wk-workflow
date: 2026-07-17
type: correction
severity: high
---

A feature gated on new env vars is not done until the vars are traced end-to-end to the code that reads them — in a containerized step, the container env allowlist is a required link.

**What happened:** A feature added a client that reads three new env vars (an
enablement flag, URL, API key) plus a build-id idempotency key, all consumed
inside a CI step that runs in a docker-compose container. The reader code, tests,
and PR body all shipped and passed review, but the docker-compose plugin's `env:`
allowlist was never extended, so the vars set at the CI-agent level never reached
the process — the feature was dead-on-arrival and emitted nothing even after the
values were provisioned. It took a live build-log inspection to surface it.

**Root cause:** Verification stopped at "code reads the var" and "value is set,"
skipping the delivery path in between. Containerized steps only receive env vars
explicitly listed in the runner's allowlist; adding a reader without the
passthrough silently produces dead code that all unit tests (which stub env) pass.

**Suggested fix:** When a change introduces a new env var consumed inside a
containerized/sandboxed step, trace the full path in the same change: producer
(agent/secret) → container/runner env allowlist → reader. Grep how a sibling
secret in the same step is forwarded and mirror it. Confirm delivery with a real
run (build log), not just green unit tests — env-stubbing tests never exercise the
plumbing.
