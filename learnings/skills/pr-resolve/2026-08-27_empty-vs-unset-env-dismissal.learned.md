---
skill: wk-pr-resolve
date: 2026-08-27
type: correction
severity: high
verified-against-source: yes
---

Agent dismissed a bot Major finding about env-var divergence as "doesn't materialize in practice" without verifying the actual execution path.

**What happened:** Bot flagged that two code paths derived the same value (pr_number) using different fallback semantics: one used `ENV.fetch("KEY", default)` (fires default only on MISSING key) and another used `empty?` detection (treats present-but-empty as absent). Agent responded that the divergence "couldn't materialize" because both vars are typically set. User corrected: docker_compose forwards declared-but-unset vars as `""`, making present-but-empty a real production scenario.

**Root cause:** Agent evaluated the finding against the happy-path env scenario, not the degenerate docker_compose forwarding behavior. The ruling "doesn't materialize" was based on ambient env assumptions without checking the actual forwarding contract documented in the codebase (`CollectorClient` and `reviewed_sha` comments both mention this explicitly).

**Suggested fix:** Before dismissing a bot finding about env-var fallback divergence, check whether the codebase documents a forwarding contract (docker_compose, CI pipeline templates) that could make the "impossible" case real. If the code already handles the degenerate case in one path, that's evidence the case IS real — the fix is to make all paths consistent, not to claim the case can't occur.
