---
skill: wk-plan
date: 2026-08-05
type: correction
severity: medium
verified-against-source: n/a
---

Separate secret consumption from secret-provisioning ownership before defining workstreams.

**What happened:** A plan added an infrastructure workstream when the application only needed a documented manual secret-population prerequisite.

**Root cause:** The plan treated the presence of a runtime secret as evidence that repository-owned infrastructure automation was required.

**Suggested fix:** Confirm the owner and provisioning mode of every secret before creating cross-repository prompts, and document manual population as an operational prerequisite when selected.
