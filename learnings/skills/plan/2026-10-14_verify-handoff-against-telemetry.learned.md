---
skill: wk-plan
date: 2026-10-14
type: pattern
severity: high
verified-against-source: yes
---

Before adopting a handoff's "fail closed on missing X" step, check telemetry for how often X is missing in a deployed environment.

**What happened:** A handoff plan said to reject identities that lack a token claim. The rejection path already
emitted a metric, and querying it showed the claim was missing on nearly every staging login, so the step would have
locked out all users. Reading the history of the earlier fix explained why: the IdP client leaves the claim out of the
token. The plan became "make it safe now, file the IdP change as a separate follow-up".

**Root cause:** Handoff notes reasoned from the spec ("the claim is mandatory") rather than from observed traffic.

**Suggested fix:** In wk-plan's Is-a-fix-warranted gate, for any reject/fail-closed step, look up the existing fallback
metric or log for that condition and quote its real-world rate before planning the step.
