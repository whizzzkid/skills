---
class: principle
source: learnings/skills/pr-resolve/2026-08-27_empty-vs-unset-env-dismissal.md
---

# Env-var divergence: check forwarding contracts before dismissing

**Rule:** Before dismissing a finding about env-var fallback divergence as
"can't happen," check whether a forwarding contract (docker_compose, CI
pipeline templates) could produce `""` for declared-but-unset vars. If one
code path already handles the degenerate case, that is evidence the case IS
real — the fix is to make all paths consistent.

**Why:** Agent evaluated a finding about `ENV.fetch("KEY", default)` vs
`empty?` detection against the happy path only. Docker_compose forwards
declared-but-unset vars as `""`, making present-but-empty a real scenario
the codebase already documented.

**Where:** Step 4, reproduction bullet — new sub-bullet on env-var divergence
verification.
