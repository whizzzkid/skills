---
skill: wk-adversarial-review
date: 2026-08-11
type: pattern
severity: low
verified-against-source: yes
---

Fail-closed rescue branches in security-sensitive code are a reliable finding
class for automated review bots — and they are consistently valid.

**What happened:** A bot flagged that a `rescue ActiveRecord::ActiveRecordError`
branch (reject subscription + report error) in an Action Cable channel had no
test, while the equivalent controller-level 503 rescues were tested. The finding
was correct and trivially fixable — stub the dependency to raise, assert
rejection and error reporting.

**Root cause:** When implementing fail-closed patterns (rescue → reject/503 →
notify), developers tend to test the happy path and the explicit-denial path but
skip the infrastructure-failure path, especially in non-controller contexts
(channels, middleware, background jobs) where the pattern is less conventional.

**Suggested fix:** When reviewing code that introduces a `rescue` block in a
security-critical path, scan for a matching spec that exercises the rescue. The
pattern is: stub the dependency to raise the rescued exception class, assert the
fail-closed outcome (rejection/503/error response) and the observability side
effect (error tracking notification). This is a high-confidence, low-effort
finding class worth keeping in the adversarial-review checklist.
