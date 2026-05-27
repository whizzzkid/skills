---
class: principle
date: 2026-05-27
source: learnings/skills/adversarial-review/2026-05-27_env-var-pipeline-forwarding-miss.md
severity: high
---

- **Rule:** Every net-new env read in application code must have its variable name appear in the env allowlist of every CI step that invokes the calling script. Allowlist locations vary by platform (Buildkite docker_compose plugin `env:` array, native step `env:`, GitHub Actions `env:`/`secrets:`, docker-compose `environment:`, Dockerfile `ENV`). Missing forwarding is a blocker — the build stays green and the feature silently no-ops at runtime.
- **Why:** Multi-layer env forwarding fails invisibly: secret store has the value, agent env dump shows it, code reads `ENV.fetch("X", default)` with a sensible default. The break is at the agent→container interface, only visible when the feature is expected to fire.
- **Where:** Step 2 mechanical sweeps — new section 2.20 "Env-var pipeline forwarding sweep", positioned alongside 2.7 (signature widening — code-to-code drift) as the code-to-pipeline analogue.
