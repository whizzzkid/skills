---
skill: wk-adversarial-review
date: 2026-07-31
type: pattern
severity: medium
verified-against-source: yes
---

Sibling browser harnesses need one shared deterministic-profile definition.

**What happened:** A new real-browser harness copied only the visible debugging preferences from
an older harness and omitted the preferences that suppress remote configuration and update
services.

**Root cause:** Deterministic profile settings were embedded in one command argument list, so a
sibling harness could look complete while silently missing its offline controls.

**Suggested fix:** When reviewing a new browser harness, compare the complete profile preference
set with every sibling harness and centralize invariant offline settings before accepting parity
claims.
