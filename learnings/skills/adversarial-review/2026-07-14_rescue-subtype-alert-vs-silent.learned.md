---
skill: wk-adversarial-review
date: 2026-07-14
type: pattern
severity: medium
---

A single broad `rescue ParentError` that fails closed can silently swallow a config/deploy bug that should page — split by subtype so the "should never happen" case alerts.

**What happened:** A fail-closed auth keyset loader rescued the whole config-error hierarchy and returned an empty keyset (deny). That is correct for the *expected* pre-provisioning state (value not yet set), but it also swallowed an *unregistered key* — a deploy/config bug — with zero signal. The bot flagged the missing observability. Fix split the rescue: `rescue UndefinedKey => e` alerts via error-tracking then denies; `rescue Error` (the expected unprovisioned case) denies quietly, because alerting there would fire on every request and drown real signal.

**Root cause:** "Fail closed" was conflated with "fail silent." Not every exception under a rescued parent class means the same thing operationally — some are the documented steady state, some are bugs that will never self-heal.

**Suggested fix:** When reviewing a `rescue`, enumerate the concrete subtypes the parent can raise and ask, per subtype: is this the expected steady state (deny quietly) or a should-never-happen bug (alert, then deny)? A broad rescue that treats a never-provisioned key and an unregistered key identically is a finding. Also verify the alerting call itself cannot raise into the response path (the metric/notify helper must self-rescue) — otherwise the observability addition becomes a new failure mode.
