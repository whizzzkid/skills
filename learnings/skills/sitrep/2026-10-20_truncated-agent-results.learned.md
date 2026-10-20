---
skill: wk-sitrep
date: 2026-10-20
type: gap
severity: medium
verified-against-source: n/a
---

Gather agents' idle-notification results truncate mid-report; the orchestrator must request remainders explicitly.

**What happened:** Every gathering agent's final result was cut off in its notification. Re-requesting "the rest" produced a second truncation for one agent; asking for a compact, one-line-per-item resend fixed it.

**Root cause:** Notification payloads have a size cap and the subagent contract only asks agents to "send results back", with no size budget.

**Suggested fix:** Add to the subagent contract: return compact one-line-per-item output (target under ~600 words) or write nothing long; orchestrator asks for the named truncated sections and a word cap in the first follow-up.
