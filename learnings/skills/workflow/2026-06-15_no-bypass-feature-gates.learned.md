---
skill: wk-workflow
date: 2026-06-15
type: correction
severity: high
---

Never add `skip_*` parameters to bypass feature gates without explicit user confirmation.

**What happened:** When extending a multi-tier auto-approve feature, the agent added a `skip_loc_threshold: true` parameter to bypass the LOC threshold gate for one tier path. The user interrupted and corrected: all existing gates (feature-enabled flag, allowlist, LOC threshold) must remain active for all tier paths — the tier only controls the message and approval criteria, not the gate logic.

**Root cause:** The agent assumed that a new tier path (tier 30-39 firing before the review runs, so no diff data is available) justified skipping the LOC gate as an "unavoidable" workaround. It did not pause to confirm whether the gate should be bypassed or simply accepted as a known limitation.

**Suggested fix:** Before adding any `skip_*`, `bypass_*`, or `force_*` parameter to an existing feature, explicitly ask the user whether the gate should be bypassed. When a gate truly cannot be honored (e.g., data unavailable at call time), document it as a known limitation rather than silently removing the protection. Never assume "unavoidable limitation" justifies removing a security or rate-limiting gate.
